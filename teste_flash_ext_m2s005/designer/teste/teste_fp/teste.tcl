open_project -project {C:\Users\Lucas\Documents\Nascerr\teste_flash_ext_m2s005\designer\teste\teste_fp\teste.pro}\
         -connect_programmers {FALSE}
load_programming_data \
    -name {M2S005} \
    -fpga {C:\Users\Lucas\Documents\Nascerr\teste_flash_ext_m2s005\designer\teste\teste.map} \
    -header {C:\Users\Lucas\Documents\Nascerr\teste_flash_ext_m2s005\designer\teste\teste.hdr} \
    -spm {C:\Users\Lucas\Documents\Nascerr\teste_flash_ext_m2s005\designer\teste\teste.spm} \
    -dca {C:\Users\Lucas\Documents\Nascerr\teste_flash_ext_m2s005\designer\teste\teste.dca}
export_spi_master \
    -name {M2S005} \
    -file {C:\Users\Lucas\Documents\Nascerr\teste_flash_ext_m2s005\designer\teste\export\teste.spi} \
    -secured

export_spi_directory \
    -golden_ver {1} \
    -golden_addr {0x1000} \
    -file {C:\Users\Lucas\Documents\Nascerr\teste_flash_ext_m2s005\designer\teste\export\teste.spidir}

save_project
close_project
