new_project \
         -name {teste} \
         -location {C:\Users\Lucas\Documents\Nascerr\teste_flash_ext_m2s005\designer\teste\teste_fp} \
         -mode {chain} \
         -connect_programmers {FALSE}
add_actel_device \
         -device {M2S005} \
         -name {M2S005}
enable_device \
         -name {M2S005} \
         -enable {TRUE}
save_project
close_project
