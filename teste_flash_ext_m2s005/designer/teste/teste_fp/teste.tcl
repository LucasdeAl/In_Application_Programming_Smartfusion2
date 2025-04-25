open_project -project {C:\Users\Lucas\Documents\Nascerr\teste_flash_ext_m2s005\designer\teste\teste_fp\teste.pro}
enable_device -name {M2S005} -enable 1
set_programming_file -name {M2S005} -file {C:\Users\Lucas\Documents\Nascerr\teste_flash_ext_m2s005\designer\teste\teste.ppd}
set_programming_action -action {PROGRAM} -name {M2S005} 
run_selected_actions
save_project
close_project
