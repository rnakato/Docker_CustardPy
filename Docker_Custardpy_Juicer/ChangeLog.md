# Changelog

## 0.3.2 (2023-02-07)
- Change the upper limit of memory in Java from `-Xmx32768m` to `-Xmx128768m`

## 0.3.1 (2022-12-12)
- Modify mega.sh to adjust CustardPy_juicer
- Add juicer_genhic.sh that generates a .hic file from the mapped data
- Deprecate `juicer_postprocessing.sh`

## 0.3.0 (2022-10-27)
- Downgrade `juicer_tools` from juicer_tools.2.13.07.jar to juicer_tools.1.22.01.jar to keep the consistency between .hic and .cool (see https://github.com/deeptools/HiCExplorer/issues/798)

## 0.2.0 (2022-08-31)
- Add restriction sites for Arima and Sau3AI
- Add restriction sites for various species
- change R installation from conda to apt

## 0.1.0
- First commit
