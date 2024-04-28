   bind dti : tb_top.mla_top.mla_pl.dti_0   probe_itf #(.WIDTH(1))   dti_probe_mclk(mclk);
   bind dti : tb_top.mla_top.mla_pl.dti_0   probe_itf #(.WIDTH(16))  dti_probe_wr_data(spi_wr_data);
   bind dti : tb_top.mla_top.mla_pl.dti_0   probe_itf #(.WIDTH(1))   dti_probe_wr_str(spi_wr_str);
   bind dti : tb_top.mla_top.mla_pl.dti_0   probe_itf #(.WIDTH(1))   dti_probe_rd_str(spi_rd_str);
   bind dti : tb_top.mla_top.mla_pl.dti_0   probe_itf #(.WIDTH(1))   dti_probe_busy(spi_busy);
   bind dti : tb_top.mla_top.mla_pl.dti_0   probe_itf #(.WIDTH(8))   dti_probe_rd_data(spi_rd_data);
