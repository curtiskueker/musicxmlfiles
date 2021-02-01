drop procedure if exists pitch_count_report;

delimiter //
create procedure pitch_count_report
	(in v_score_id int)
proc: begin
	declare v_pitch_count int;
	declare v_pitch_number int;
	declare v_music_data_type varchar(255);
	declare v_step varchar(255);
	declare v_pitch_alter int;
	declare v_transposition int;
	declare is_tied boolean;

	select music_data_type, step, pitch_alter, transposition, tied from report_current_music_data into v_music_data_type, v_step, v_pitch_alter, v_transposition, is_tied;

	if v_music_data_type != 'note' then leave proc; end if;
	if is_tied then leave proc; end if;

    set v_pitch_number = pitch_number(v_step, v_pitch_alter, v_transposition);
    if v_pitch_number is null then leave proc; end if;

    select pitch_count into v_pitch_count from report_pitch_counts where score_id = v_score_id and pitch = v_pitch_number;
    if v_pitch_count is null then
        insert into report_pitch_counts (score_id, pitch, pitch_count) values (v_score_id, v_pitch_number, 1);
    else
        set v_pitch_count = v_pitch_count + 1;
        update report_pitch_counts set pitch_count = v_pitch_count where score_id = v_score_id and pitch = v_pitch_number;
    end if;
end //
delimiter ;
