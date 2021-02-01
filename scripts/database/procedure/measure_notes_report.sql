drop procedure if exists measure_notes_report;

delimiter //
create procedure measure_notes_report
	(in v_score_id int)
proc: begin
    declare v_music_data_type varchar(255);
    declare v_grace_id int;
    declare is_new_measure boolean;
    declare v_report_measure_id int;
    declare v_measure_number varchar(255);
	declare v_step varchar(255);
	declare v_pitch_alter int;
	declare v_current_transposition int;

    select music_data_type, grace_id, new_measure, measure_number, step, pitch_alter, transposition from report_current_music_data
    into v_music_data_type, v_grace_id, is_new_measure, v_measure_number, v_step, v_pitch_alter, v_current_transposition;

    if v_music_data_type != 'note' or v_grace_id is not null or not is_new_measure then leave proc; end if;

    select id from report_measure where score_id = v_score_id and measure_number = v_measure_number into v_report_measure_id;
    if v_report_measure_id is null then
        select concat('report_measure record not found for measure number ', v_measure_number) as message;
        leave proc;
    end if;

    if pitch_number(v_step, v_pitch_alter, v_current_transposition) is not null then
        insert into report_measure_notes (report_measure_id, step, pitch_alter, transpose)
        values (v_report_measure_id, v_step, v_pitch_alter, v_current_transposition);
    end if;
end //
delimiter ;
