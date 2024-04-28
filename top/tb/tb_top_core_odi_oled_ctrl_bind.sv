   bind spi_ctrl    : tb_top.mla_top.mla_pl.odi_0.oled_ctrl_0.Initialize.spi_comp    probe_itf #(.WIDTH(1))  initilize_spi_comp_probe_en(en);
   bind spi_ctrl    : tb_top.mla_top.mla_pl.odi_0.oled_ctrl_0.Initialize.spi_comp    probe_itf #(.WIDTH(8))  initilize_spi_comp_probe_sdata(sdata);
   bind spi_ctrl    : tb_top.mla_top.mla_pl.odi_0.oled_ctrl_0.Example.spi_comp       probe_itf #(.WIDTH(1))  example_spi_comp_probe_en(en);
   bind spi_ctrl    : tb_top.mla_top.mla_pl.odi_0.oled_ctrl_0.Example.spi_comp       probe_itf #(.WIDTH(8))  example_spi_comp_probe_sdata(sdata);
   bind oled_init   : tb_top.mla_top.mla_pl.odi_0.oled_ctrl_0.Initialize             probe_itf #(.WIDTH(1))  initialize_probe_init_done(fin);
   bind oled_ex     : tb_top.mla_top.mla_pl.odi_0.oled_ctrl_0.Example                probe_itf #(.WIDTH(1))  example_probe_alphabet_done_str(alphabet_done_str);
