drop procedure if exists score_report;

delimiter //
create procedure score_report
(in v_procedure_name varchar(255), in v_score_id int)
proc: begin
    declare is_end_of_data boolean default false;
    declare is_report_run boolean default false;
    declare v_score_name varchar(255);
    declare v_current_transposition int;
    declare v_current_part_id int default 0;
    declare v_part_id int default 0;
    declare v_current_measure_number varchar(255) default '';
    declare v_measure_number varchar(255);
    declare v_music_data_id int;
    declare v_music_data_type varchar(255);
    declare v_voice varchar(255);
    declare v_current_measure_duration int default 0;
    declare v_previous_duration int default 0;
    declare v_duration int;
    declare is_new_measure boolean;
    declare v_octave int;
    declare v_previous_octave int;
    declare v_grace_id int;
    declare is_chord boolean;
    declare v_note_type_type varchar(255);
    declare v_chromatic int;
    declare v_step varchar(255);
    declare v_previous_step varchar(255);
    declare v_pitch_alter int;
    declare v_previous_pitch_alter int;
    declare is_measures_handled boolean;
    declare is_first_part boolean;
    declare v_report_measure_id int;
    declare v_ordering int;

    declare c_score_items cursor for
        select part_id, measure_number, music_data_id, music_data_type, voice, duration, grace_id, chord, note_type_type, step, pitch_alter, octave, chromatic
        from score_view
        where score_id = v_score_id;

    declare continue handler for not found set is_end_of_data = true;

    declare exit handler for sqlexception
        begin
            get diagnostics condition 1 @error_message = message_text;
            select @error_message as error_message;
            rollback to report_run;
        end;

    create table if not exists report_run (
        score_id int,
        procedure_name varchar(255),
        unique (score_id, procedure_name)
    );

    create table if not exists report_measure (
        id int,
        score_id int,
        measure_number varchar(255),
        ordering int,
        unique (score_id, measure_number)
    );

    create temporary table if not exists report_current_music_data (
        measure_number varchar(255),
        music_data_type varchar(31),
        transposition int,
        note_type_type varchar(31),
        tied boolean,
        chord boolean,
        octave int,
        step varchar(255),
        pitch_alter int,
        previous_octave int,
        previous_step varchar(255),
        previous_pitch_alter int,
        new_measure boolean,
        grace_id int
    );

    create temporary table if not exists report_previous_voice_note (
        voice varchar(255),
        octave int,
        step varchar(255),
        pitch_alter int
    );

    if not exists(select id from score where id = v_score_id) then
        set @message_text = concat('Score ID ', v_score_id, ' not found');
        signal sqlstate '45000' set message_text = @message_text;
    end if;

    if exists(select score_id from report_run where score_id = v_score_id and procedure_name = v_procedure_name) then
        set @message_text = concat('Report ', v_procedure_name, ' already run for score ', v_score_id);
        signal sqlstate '45000' set message_text = @message_text;
    end if;

    select score_name from score where id = v_score_id into v_score_name;

    select concat('Running report ', v_procedure_name, ' for score id ', v_score_id, ', score name ', v_score_name) as message;

    start transaction;
    savepoint report_run;

    set @s_procedure_statement = concat('call ', v_procedure_name, '(', v_score_id, ')');
    prepare s_procedure_statement from @s_procedure_statement;

    set is_measures_handled = exists(select score_id from report_measure where score_id = v_score_id);

    open c_score_items;
    score_items_loop: loop
        fetch c_score_items into
            v_part_id, v_measure_number, v_music_data_id, v_music_data_type,
            v_voice, v_duration, v_grace_id, is_chord, v_note_type_type,
            v_step, v_pitch_alter, v_octave, v_chromatic;
        if is_end_of_data then leave score_items_loop; end if;
        if v_part_id != v_current_part_id then
            if v_current_part_id = 0 then
                set is_first_part = true;
            else set is_first_part = false;
            end if;
            set v_current_transposition = null;
            set v_current_part_id = v_part_id;
            delete from report_previous_voice_note;
        end if;
        if v_measure_number != v_current_measure_number then
            if is_first_part and not is_measures_handled then
                select coalesce(max(id) + 1, 1) from report_measure into v_report_measure_id;
                select coalesce(max(ordering) + 1, 1) from report_measure where score_id = v_score_id into v_ordering;
                insert into report_measure (id, score_id, measure_number, ordering) values (v_report_measure_id, v_score_id, v_measure_number, v_ordering);
            end if;
            set v_current_measure_number = v_measure_number;
            set v_current_measure_duration = 0;
        end if;

        -- process the music data type
        case v_music_data_type
            when 'attributes' then
                if v_chromatic is not null then set v_current_transposition = v_chromatic; end if;
            when 'backup' then
                set v_current_measure_duration = v_current_measure_duration - v_duration;
            when 'forward' then
                set v_current_measure_duration = v_current_measure_duration + v_duration;
            when 'note' then
                if v_note_type_type = 'rest' then
                    delete from report_previous_voice_note where voice = v_voice;
                elseif v_note_type_type = 'pitch' then
                    if not is_chord then
                        if exists (select voice from report_previous_voice_note where voice = v_voice) then
                            select octave, step, pitch_alter into v_previous_octave, v_previous_step, v_previous_pitch_alter
                            from report_previous_voice_note where voice = v_voice;
                            update report_previous_voice_note set octave = v_octave, step = v_step, pitch_alter = v_pitch_alter where voice = v_voice;
                        else
                            set v_previous_octave = null;
                            set v_previous_step = null;
                            set v_previous_pitch_alter = null;
                            insert into report_previous_voice_note (voice, octave, step, pitch_alter) values (v_voice, v_octave, v_step, v_pitch_alter);
                        end if;
                    end if;
                end if;
                if is_chord then set v_current_measure_duration = v_current_measure_duration - v_previous_duration; end if;
                if v_current_measure_duration = 0 then
                    set is_new_measure = true;
                else
                    set is_new_measure = false;
                end if;
                set v_current_measure_duration = v_current_measure_duration + v_duration;
                set v_previous_duration = v_duration;
            else begin end;
            end case;

        -- replace current state used by reports procedures
        delete from report_current_music_data;
        insert into report_current_music_data
            (measure_number, music_data_type, transposition, note_type_type, tied, chord,
             octave, step, pitch_alter, previous_octave, previous_step, previous_pitch_alter, new_measure, grace_id)
            values
            (v_measure_number, v_music_data_type, v_current_transposition, v_note_type_type, is_tied_note(v_music_data_id), is_chord,
             v_octave, v_step, v_pitch_alter, v_previous_octave, v_previous_step, v_previous_pitch_alter, is_new_measure, v_grace_id);

        -- run a report
        execute s_procedure_statement;
        set is_report_run = true;

    end loop;
    close c_score_items;
    deallocate prepare s_procedure_statement;

    if is_report_run then insert into report_run (score_id, procedure_name) values (v_score_id, v_procedure_name); end if;
    drop temporary table if exists report_previous_voice_note;
    drop temporary table if exists report_current_music_data;

    commit;

    select 'Report run complete' as message;
end //
delimiter ;
