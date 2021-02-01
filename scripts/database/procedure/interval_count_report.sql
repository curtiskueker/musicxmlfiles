drop procedure if exists interval_count_report;

delimiter //
create procedure interval_count_report
(in v_score_id int)
proc: begin
    declare v_interval_count int;
    declare v_interval_number int;
    declare v_music_data_type varchar(255);
    declare v_note_type_type varchar(255);
    declare is_tied boolean;
    declare is_chord boolean;
    declare v_step varchar(255);
    declare v_previous_step varchar(255);
    declare v_pitch_alter int;
    declare v_previous_pitch_alter int;
    declare v_octave int;
    declare v_previous_octave int;

    select music_data_type, note_type_type, tied, chord, step, previous_step, pitch_alter, previous_pitch_alter, octave, previous_octave from report_current_music_data
    into v_music_data_type, v_note_type_type, is_tied, is_chord, v_step, v_previous_step, v_pitch_alter, v_previous_pitch_alter, v_octave, v_previous_octave;

    if v_music_data_type != 'note' and v_note_type_type != 'pitch' then leave proc; end if;
    if is_tied then leave proc; end if;
    if is_chord then leave proc; end if;

    if v_step is null or v_previous_step is null then leave proc; end if;

    set v_interval_number = pitch_number(v_step, v_pitch_alter, null) - pitch_number(v_previous_step, v_previous_pitch_alter, null);
    if v_octave is not null and v_previous_octave is not null then
        set v_interval_number = v_interval_number + ((v_octave * 12) - (v_previous_octave * 12));
    end if;
    select interval_count into v_interval_count from report_interval_counts where score_id = v_score_id and pitch_interval = v_interval_number;
    if v_interval_count is null then
        insert into report_interval_counts (score_id, pitch_interval, interval_count) values (v_score_id, v_interval_number, 1);
    else
        set v_interval_count = v_interval_count + 1;
        update report_interval_counts set interval_count = v_interval_count where score_id = v_score_id and pitch_interval = v_interval_number;
    end if;
end //
delimiter ;
