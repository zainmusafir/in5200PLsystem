   bind dti_spi : tb_top.mla_top.mla_pl.dti_0.dti_spi_0   probe_itf #(.WIDTH(1))   dti_spi_probe_mclk(mclk);
   bind dti_spi : tb_top.mla_top.mla_pl.dti_0.dti_spi_0   probe_itf #(.WIDTH(8))   dti_spi_probe_instr(instr);
   bind dti_spi : tb_top.mla_top.mla_pl.dti_0.dti_spi_0   probe_itf #(.WIDTH(8))   dti_spi_probe_wdata(wdata);
   bind dti_spi : tb_top.mla_top.mla_pl.dti_0.dti_spi_0   probe_itf #(.WIDTH(1))   dti_spi_probe_wr_str(wr_str);
   bind dti_spi : tb_top.mla_top.mla_pl.dti_0.dti_spi_0   probe_itf #(.WIDTH(1))   dti_spi_probe_rd_str(rd_str);
   bind dti_spi : tb_top.mla_top.mla_pl.dti_0.dti_spi_0   probe_itf #(.WIDTH(1))   dti_spi_probe_busy(busy);
   bind dti_spi : tb_top.mla_top.mla_pl.dti_0.dti_spi_0   probe_itf #(.WIDTH(8))   dti_spi_probe_rdata(rdata);
