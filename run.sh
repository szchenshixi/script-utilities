#!/bin/bash

print_usage() {
    __usage=$(cat <<EOF
Usage: $(basename $0) KEY[:SUBKEY:...] ...
Run pre-defined commands that matches the search keys. Each key is for a set of
commands.
Example:
    Run with 3 sets of commands
        \033[1mrun.sh fft:1e4 fft:5e4 lu\033[0m
    Run all pre-defined commands with 4 threads
        \033[1mrun.sh -j4 .\033[0m
Options:
  -h, --help              Display help
  -j [N], --jobs[=N]      Allow N jobs at once; 2 by default
EOF
)
    echo -e "$__usage"
    exit
}

[ $# -eq 0 ] && print_usage && exit
# Use GNU 'getopt' to parse input options
SHORT="h,j:"
LONG="help,jobs:"
NUM_PROC=2
eval set -- $(getopt --options $SHORT --long $LONG  -- "$@")
unset SHORT
unset LONG
while [[ $# -gt 0 ]]; do
    case "$1" in
    -h | --help)
        print_usage
        shift
        exit
        ;;
    -j | --jobs)
        NUM_PROC="$2"
        shift 2
        ;;
    -- )
        shift
        break
        ;;
    *)
        # Nothing to do
        break
        ;;
    esac
done

#----------------------------------------------------------------------
# Modify to use different jade instance
isa=aarch64
proto=cluster_msi_w_laser_banks
# proto=cluster_msi_wo_laser_banks
# proto=cluster_msi_wo_laser_banks
# proto=cluster_msi_w_laser_banks_5e5
# proto=cluster_msi_w_laser_banks_1e4
# Comment for this run. Used as indentifiers of the output

RESULT_ROOT=./result/$(date +"%Y-%m-%d")
LOG_ROOT=./log/$(date +"%Y-%m-%d")
#----------------------------------------------------------------------

# jade executables for different protocols
jade_msi=./workspace/${isa}_msi_mosi_cmp_directory/bin/jade.exec
jade_mesi=./workspace/${isa}_mesi_cmp_directory/bin/jade.exec
jade_moesi=./workspace/${isa}_moesi_cmp_directory/bin/jade.exec
jade_cluster_msi=./workspace/${isa}-cluster-camon_cluster_msi_mosi/bin/jade.exec
jade_cluster_msi_wo_laser_banks=./workspace/${isa}-cluster-camon_cluster_msi_mosi/bin/wo_laser_banks/jade.exec
jade_cluster_msi_w_laser_banks=./workspace/${isa}-cluster-camon_cluster_msi_mosi/bin/w_laser_banks/jade.exec

# select the right executable
case $proto in
'msi')
    jade=$jade_msi
    ;;
'mesi')
    jade=$jade_mesi
    ;;
'moesi')
    jade=$jade_moesi
    ;;
'cluster_msi')
    jade=$jade_cluster_msi
    ;;
'cluster_msi_w_laser_banks')
    jade=$jade_cluster_msi_w_laser_banks
    ;;
'cluster_msi_wo_laser_banks')
    jade=$jade_cluster_msi_wo_laser_banks
    ;;
*)
    echo "No valid Jade is selcted. Abort."
    exit
esac

go() {
    mkdir -p $RESULT_ROOT
    mkdir -p $LOG_ROOT
    # Run jade
    echo -e "$jade $@\n\n"
}

gofft_simple() {
    comment=WithoutLaserBank
    go \
        -w ./architectures/net/mesh_8x16.txt \
        --sampling-rate 10 \
        --mtsyn ./applications/shalom/aarch64/splash/fft/128.txt \
        -O ${RESULT_ROOT}/FFT_${proto}_mesh_128.txt \
        --g_JADE_E_NETWORK 0 \
        --g_JADE_wzh 1 \
        \| tee $LOG_ROOT/fft_${proto}_mesh_128_$(date +"%Y%m%d-%H%M").log 2>&1

}

gofft() {
    comment=WithLaserBank-1e3psKeepAliveTime
    go \
        -w ./architectures/net/CAMON_128.txt \
        --sampling-rate 10 \
        --mtsyn ./applications/shalom/aarch64/splash/fft/128.txt \
        -O ${RESULT_ROOT}/FFT_${proto}_CAMON_128_${comment}_$(date +"%Y%m%d-%H%M").txt \
        --g_LaserBank_config_file ./network/jade-wzh/LaserBank/config/LaserBank1e3Config.yaml \
        --g_JADE_E_NETWORK 0 \
        --g_JADE_CAMON_NETWORK 1 \
        \| tee ${LOG_ROOT}/fft_${proto}_128_${comment}_$(date +"%Y%m%d-%H%M").log 2>&1

    comment=WithLaserBank-5e3psKeepAliveTime
    go \
        -w ./architectures/net/CAMON_128.txt \
        --sampling-rate 10 \
        --mtsyn ./applications/shalom/aarch64/splash/fft/128.txt \
        -O ${RESULT_ROOT}/FFT_${proto}_CAMON_128_${comment}_$(date +"%Y%m%d-%H%M").txt \
        --g_LaserBank_config_file ./network/jade-wzh/LaserBank/config/LaserBank5e3Config.yaml \
        --g_JADE_E_NETWORK 0 \
        --g_JADE_CAMON_NETWORK 1 \
        \| tee ${LOG_ROOT}/fft_${proto}_128_${comment}_$(date +"%Y%m%d-%H%M").log 2>&1

    comment=WithLaserBank-1e4psKeepAliveTime
    go \
        -w ./architectures/net/CAMON_128.txt \
        --sampling-rate 10 \
        --mtsyn ./applications/shalom/aarch64/splash/fft/128.txt \
        -O ${RESULT_ROOT}/FFT_${proto}_CAMON_128_${comment}_$(date +"%Y%m%d-%H%M").txt \
        --g_LaserBank_config_file ./network/jade-wzh/LaserBank/config/LaserBank1e4Config.yaml \
        --g_JADE_E_NETWORK 0 \
        --g_JADE_CAMON_NETWORK 1 \
        \| tee ${LOG_ROOT}/fft_${proto}_128_${comment}_$(date +"%Y%m%d-%H%M").log 2>&1

    comment=WithLaserBank-5e4psKeepAliveTime
    go \
        -w ./architectures/net/CAMON_128.txt \
        --sampling-rate 10 \
        --mtsyn ./applications/shalom/aarch64/splash/fft/128.txt \
        -O ${RESULT_ROOT}/FFT_${proto}_CAMON_128_${comment}_$(date +"%Y%m%d-%H%M").txt \
        --g_LaserBank_config_file ./network/jade-wzh/LaserBank/config/LaserBank5e4Config.yaml \
        --g_JADE_E_NETWORK 0 \
        --g_JADE_CAMON_NETWORK 1 \
        \| tee ${LOG_ROOT}/fft_${proto}_128_${comment}_$(date +"%Y%m%d-%H%M").log 2>&1

    comment=WithLaserBank-1e5psKeepAliveTime
    go \
        -w ./architectures/net/CAMON_128.txt \
        --sampling-rate 10 \
        --mtsyn ./applications/shalom/aarch64/splash/fft/128.txt \
        -O ${RESULT_ROOT}/FFT_${proto}_CAMON_128_${comment}_$(date +"%Y%m%d-%H%M").txt \
        --g_LaserBank_config_file ./network/jade-wzh/LaserBank/config/LaserBank1e5Config.yaml \
        --g_JADE_E_NETWORK 0 \
        --g_JADE_CAMON_NETWORK 1 \
        \| tee ${LOG_ROOT}/fft_${proto}_128_${comment}_$(date +"%Y%m%d-%H%M").log 2>&1

    comment=WithLaserBank-5e5psKeepAliveTime
    go \
        -w ./architectures/net/CAMON_128.txt \
        --sampling-rate 10 \
        --mtsyn ./applications/shalom/aarch64/splash/fft/128.txt \
        -O ${RESULT_ROOT}/FFT_${proto}_CAMON_128_${comment}_$(date +"%Y%m%d-%H%M").txt \
        --g_LaserBank_config_file ./network/jade-wzh/LaserBank/config/LaserBank5e5Config.yaml \
        --g_JADE_E_NETWORK 0 \
        --g_JADE_CAMON_NETWORK 1 \
        \| tee ${LOG_ROOT}/fft_${proto}_128_${comment}_$(date +"%Y%m%d-%H%M").log 2>&1

    comment=WithLaserBank-1e6psKeepAliveTime
    go \
        -w ./architectures/net/CAMON_128.txt \
        --sampling-rate 10 \
        --mtsyn ./applications/shalom/aarch64/splash/fft/128.txt \
        -O ${RESULT_ROOT}/FFT_${proto}_CAMON_128_${comment}_$(date +"%Y%m%d-%H%M").txt \
        --g_LaserBank_config_file ./network/jade-wzh/LaserBank/config/LaserBank1e6Config.yaml \
        --g_JADE_E_NETWORK 0 \
        --g_JADE_CAMON_NETWORK 1 \
        \| tee ${LOG_ROOT}/fft_${proto}_128_${comment}_$(date +"%Y%m%d-%H%M").log 2>&1

    # go \
    #     -w ./architectures/net/mesh_16x16_CAMON.txt \
    #     --sampling-rate 10 \
    #     --mtsyn ./applications/shalom/aarch64/splash/fft/256.txt \
    #     -O ${RESULT_ROOT}/FFT_${proto}_CAMON_256.txt \
    #     --g_JADE_E_NETWORK 0 \
    #     --g_JADE_wzh 1 \
    #     \| tee $LOG_ROOT/fft_${proto}_256_$(date +"%Y%m%d-%H%M").log 2>&1

    # There is no 512-thread benchmark
    # go \
    #     -w ./architectures/net/mesh_16x32_CAMON.txt                 \
    #     --sampling-rate 10                                          \
    #     --mtsyn ./applications/shalom/aarch64/splash/fft/512.txt    \
    #     -O ${RESULT_ROOT}/FFT_msi_CAMON_512.txt 2>&1                      \
    #     \| tee $LOG_ROOT/fft_512_`date +"%Y%m%d-%H%M"`.log              \

    # go \
    #     -w ./architectures/net/mesh_8x16.txt \
    #     --sampling-rate 10 \
    #     --mtsyn ./applications/shalom/aarch64/splash/fft/128.txt \
    #     -O ${RESULT_ROOT}/FFT_${proto}_non-CAMON_128.txt \
    #     \| tee $LOG_ROOT/fft_${proto}_128_$(date +"%Y%m%d-%H%M").log 2>&1

}

golu_simple() {
    comment=WithoutLaserBank
    go \
        -w ./architectures/net/mesh_8x16_CAMON.txt \
        --sampling-rate 10 \
        --mtsyn ./applications/shalom/aarch64/splash/lu/contiguous_blocks/128.txt \
        -O ${RESULT_ROOT}/LU_${proto}_CAMON_128_${comment}.txt \
        --g_JADE_E_NETWORK 0 \
        --g_JADE_CAMON_NETWORK 1 \
        \| tee ${LOG_ROOT}/lu_${proto}_128_${comment}_$(date +"%Y%m%d-%H%M").log 2>&1

}

golu() {
    comment=WithLaserBank-1e3psKeepAliveTime
    go \
        -w ./architectures/net/mesh_8x16_CAMON.txt \
        --sampling-rate 10 \
        --mtsyn ./applications/shalom/aarch64/splash/lu/contiguous_blocks/128.txt \
        -O ${RESULT_ROOT}/LU_${proto}_CAMON_128_${comment}.txt \
        --g_LaserBank_config_file ./network/jade-wzh/LaserBank/config/LaserBank1e3Config.yaml \
        --g_JADE_E_NETWORK 0 \
        --g_JADE_CAMON_NETWORK 1 \
        \| tee ${LOG_ROOT}/lu_${proto}_128_${comment}_$(date +"%Y%m%d-%H%M").log 2>&1

    comment=WithLaserBank-5e3psKeepAliveTime
    go \
        -w ./architectures/net/mesh_8x16_CAMON.txt \
        --sampling-rate 10 \
        --mtsyn ./applications/shalom/aarch64/splash/lu/contiguous_blocks/128.txt \
        -O ${RESULT_ROOT}/LU_${proto}_CAMON_128_${comment}.txt \
        --g_LaserBank_config_file ./network/jade-wzh/LaserBank/config/LaserBank5e3Config.yaml \
        --g_JADE_E_NETWORK 0 \
        --g_JADE_CAMON_NETWORK 1 \
        \| tee ${LOG_ROOT}/lu_${proto}_128_${comment}_$(date +"%Y%m%d-%H%M").log 2>&1

    comment=WithLaserBank-1e4psKeepAliveTime
    go \
        -w ./architectures/net/mesh_8x16_CAMON.txt \
        --sampling-rate 10 \
        --mtsyn ./applications/shalom/aarch64/splash/lu/contiguous_blocks/128.txt \
        -O ${RESULT_ROOT}/LU_${proto}_CAMON_128_${comment}.txt \
        --g_LaserBank_config_file ./network/jade-wzh/LaserBank/config/LaserBank1e4Config.yaml \
        --g_JADE_E_NETWORK 0 \
        --g_JADE_CAMON_NETWORK 1 \
        \| tee ${LOG_ROOT}/lu_${proto}_128_${comment}_$(date +"%Y%m%d-%H%M").log 2>&1

    comment=WithLaserBank-5e4psKeepAliveTime
    go \
        -w ./architectures/net/mesh_8x16_CAMON.txt \
        --sampling-rate 10 \
        --mtsyn ./applications/shalom/aarch64/splash/lu/contiguous_blocks/128.txt \
        -O ${RESULT_ROOT}/LU_${proto}_CAMON_128_${comment}.txt \
        --g_LaserBank_config_file ./network/jade-wzh/LaserBank/config/LaserBank5e4Config.yaml \
        --g_JADE_E_NETWORK 0 \
        --g_JADE_CAMON_NETWORK 1 \
        \| tee ${LOG_ROOT}/lu_${proto}_128_${comment}_$(date +"%Y%m%d-%H%M").log 2>&1

    comment=WithLaserBank-1e5psKeepAliveTime
    go \
        -w ./architectures/net/mesh_8x16_CAMON.txt \
        --sampling-rate 10 \
        --mtsyn ./applications/shalom/aarch64/splash/lu/contiguous_blocks/128.txt \
        -O ${RESULT_ROOT}/LU_${proto}_CAMON_128_${comment}.txt \
        --g_LaserBank_config_file ./network/jade-wzh/LaserBank/config/LaserBank1e5Config.yaml \
        --g_JADE_E_NETWORK 0 \
        --g_JADE_CAMON_NETWORK 1 \
        \| tee ${LOG_ROOT}/lu_${proto}_128_${comment}_$(date +"%Y%m%d-%H%M").log 2>&1

    comment=WithLaserBank-5e5psKeepAliveTime
    go \
        -w ./architectures/net/mesh_8x16_CAMON.txt \
        --sampling-rate 10 \
        --mtsyn ./applications/shalom/aarch64/splash/lu/contiguous_blocks/128.txt \
        -O ${RESULT_ROOT}/LU_${proto}_CAMON_128_${comment}.txt \
        --g_LaserBank_config_file ./network/jade-wzh/LaserBank/config/LaserBank5e5Config.yaml \
        --g_JADE_E_NETWORK 0 \
        --g_JADE_CAMON_NETWORK 1 \
        \| tee ${LOG_ROOT}/lu_${proto}_128_${comment}_$(date +"%Y%m%d-%H%M").log 2>&1

    comment=WithLaserBank-1e6psKeepAliveTime
    go \
        -w ./architectures/net/mesh_8x16_CAMON.txt \
        --sampling-rate 10 \
        --mtsyn ./applications/shalom/aarch64/splash/lu/contiguous_blocks/128.txt \
        -O ${RESULT_ROOT}/LU_${proto}_CAMON_128_${comment}.txt \
        --g_LaserBank_config_file ./network/jade-wzh/LaserBank/config/LaserBank1e6Config.yaml \
        --g_JADE_E_NETWORK 0 \
        --g_JADE_CAMON_NETWORK 1 \
        \| tee ${LOG_ROOT}/lu_${proto}_128_${comment}_$(date +"%Y%m%d-%H%M").log 2>&1

}

govolrend() {
    go \
        -w ./architectures/net/mesh_8x16_CAMON.txt \
        --sampling-rate 10 \
        --mtsyn ./applications/shalom/aarch64/splash/volrend/128.txt \
        -O ${RESULT_ROOT}/VOLREND_${proto}_CAMON_128_${comment}.txt \
        \| tee ${LOG_ROOT}/volrend_${proto}_128_${comment}_$(date +"%Y%m%d-%H%M").log 2>&1

}

gobarnes() {
    go \
        -w ./architectures/net/mesh_8x16_CAMON.txt \
        --sampling-rate 10 \
        --mtsyn ./applications/shalom/aarch64/splash/barnes/128.txt \
        -O ${RESULT_ROOT}/barnes_${proto}_CAMON_128_${comment}.txt \
        \| tee ${LOG_ROOT}/barnes_${proto}_128_${comment}_$(date +"%Y%m%d-%H%M").log 2>&1

}

gowater-spatial() {
    go \
        -w ./architectures/net/mesh_8x16_CAMON.txt \
        --sampling-rate 10 \
        --mtsyn ./applications/shalom/aarch64/splash/water-spatial/128.txt \
        -O ${RESULT_ROOT}/WATER-SPATIAL_${proto}_CAMON_128_${comment}.txt \
        \| tee ${LOG_ROOT}/water-spatial_${proto}_128_${comment}_$(date +"%Y%m%d-%H%M").log 2>&1

}

gofmm() {
    # comment=WithoutLaserBank
    # go \
    #     -w ./architectures/net/mesh_8x16_CAMON.txt \
    #     --sampling-rate 10 \
    #     --mtsyn ./applications/shalom/aarch64/splash/fmm/128.txt \
    #     -O ${RESULT_ROOT}/FMM_${proto}_CAMON_128_${comment}.txt \
    #     --g_JADE_E_NETWORK 0 \
    #     --g_JADE_CAMON_NETWORK 1 \
    #     \| tee ${LOG_ROOT}/fmm_${proto}_128_${comment}_$(date +"%Y%m%d-%H%M").log 2>&1

    comment=WithLaserBank-1e3psKeepAliveTime
    go \
        -w ./architectures/net/mesh_8x16_CAMON.txt \
        --sampling-rate 10 \
        --mtsyn ./applications/shalom/aarch64/splash/fmm/128.txt \
        -O ${RESULT_ROOT}/FMM_${proto}_CAMON_128_${comment}.txt \
        --g_LaserBank_config_file ./network/jade-wzh/LaserBank/config/LaserBank1e3Config.yaml \
        --g_JADE_E_NETWORK 0 \
        --g_JADE_CAMON_NETWORK 1 \
        \| tee ${LOG_ROOT}/fmm_${proto}_128_${comment}_$(date +"%Y%m%d-%H%M").log 2>&1

    comment=WithLaserBank-5e3psKeepAliveTime
    go \
        -w ./architectures/net/mesh_8x16_CAMON.txt \
        --sampling-rate 10 \
        --mtsyn ./applications/shalom/aarch64/splash/fmm/128.txt \
        -O ${RESULT_ROOT}/FMM_${proto}_CAMON_128_${comment}.txt \
        --g_LaserBank_config_file ./network/jade-wzh/LaserBank/config/LaserBank5e3Config.yaml \
        --g_JADE_E_NETWORK 0 \
        --g_JADE_CAMON_NETWORK 1 \
        \| tee ${LOG_ROOT}/fmm_${proto}_128_${comment}_$(date +"%Y%m%d-%H%M").log 2>&1

    comment=WithLaserBank-1e4psKeepAliveTime
    go \
        -w ./architectures/net/mesh_8x16_CAMON.txt \
        --sampling-rate 10 \
        --mtsyn ./applications/shalom/aarch64/splash/fmm/128.txt \
        -O ${RESULT_ROOT}/FMM_${proto}_CAMON_128_${comment}.txt \
        --g_LaserBank_config_file ./network/jade-wzh/LaserBank/config/LaserBank1e4Config.yaml \
        --g_JADE_E_NETWORK 0 \
        --g_JADE_CAMON_NETWORK 1 \
        \| tee ${LOG_ROOT}/fmm_${proto}_128_${comment}_$(date +"%Y%m%d-%H%M").log 2>&1

    comment=WithLaserBank-5e4psKeepAliveTime
    go \
        -w ./architectures/net/mesh_8x16_CAMON.txt \
        --sampling-rate 10 \
        --mtsyn ./applications/shalom/aarch64/splash/fmm/128.txt \
        -O ${RESULT_ROOT}/FMM_${proto}_CAMON_128_${comment}.txt \
        --g_LaserBank_config_file ./network/jade-wzh/LaserBank/config/LaserBank5e4Config.yaml \
        --g_JADE_E_NETWORK 0 \
        --g_JADE_CAMON_NETWORK 1 \
        \| tee ${LOG_ROOT}/fmm_${proto}_128_${comment}_$(date +"%Y%m%d-%H%M").log 2>&1

    comment=WithLaserBank-1e5psKeepAliveTime
    go \
        -w ./architectures/net/mesh_8x16_CAMON.txt \
        --sampling-rate 10 \
        --mtsyn ./applications/shalom/aarch64/splash/fmm/128.txt \
        -O ${RESULT_ROOT}/FMM_${proto}_CAMON_128_${comment}.txt \
        --g_LaserBank_config_file ./network/jade-wzh/LaserBank/config/LaserBank1e5Config.yaml \
        --g_JADE_E_NETWORK 0 \
        --g_JADE_CAMON_NETWORK 1 \
        \| tee ${LOG_ROOT}/fmm_${proto}_128_${comment}_$(date +"%Y%m%d-%H%M").log 2>&1

    comment=WithLaserBank-5e5psKeepAliveTime
    go \
        -w ./architectures/net/mesh_8x16_CAMON.txt \
        --sampling-rate 10 \
        --mtsyn ./applications/shalom/aarch64/splash/fmm/128.txt \
        -O ${RESULT_ROOT}/FMM_${proto}_CAMON_128_${comment}.txt \
        --g_LaserBank_config_file ./network/jade-wzh/LaserBank/config/LaserBank5e5Config.yaml \
        --g_JADE_E_NETWORK 0 \
        --g_JADE_CAMON_NETWORK 1 \
        \| tee ${LOG_ROOT}/fmm_${proto}_128_${comment}_$(date +"%Y%m%d-%H%M").log 2>&1

    comment=WithLaserBank-1e6psKeepAliveTime
    go \
        -w ./architectures/net/mesh_8x16_CAMON.txt \
        --sampling-rate 10 \
        --mtsyn ./applications/shalom/aarch64/splash/fmm/128.txt \
        -O ${RESULT_ROOT}/FMM_${proto}_CAMON_128_${comment}.txt \
        --g_LaserBank_config_file ./network/jade-wzh/LaserBank/config/LaserBank1e6Config.yaml \
        --g_JADE_E_NETWORK 0 \
        --g_JADE_CAMON_NETWORK 1 \
        \| tee ${LOG_ROOT}/fmm_${proto}_128_${comment}_$(date +"%Y%m%d-%H%M").log 2>&1

}

gocholesky_simple() {
    comment=WithoutLaserBank
    go \
        -w ./architectures/net/mesh_8x16_CAMON.txt \
        --sampling-rate 10 \
        --mtsyn ./applications/shalom/aarch64/splash/cholesky/128.txt \
        -O ${RESULT_ROOT}/CHOLESKY_${proto}_CAMON_128_${comment}.txt \
        --g_JADE_E_NETWORK 0 \
        --g_JADE_CAMON_NETWORK 1 \
        \| tee ${LOG_ROOT}/cholesky_${proto}_128_${comment}_$(date +"%Y%m%d-%H%M").log 2>&1

}

gocholesky() {
    comment=WithLaserBank-1e3psKeepAliveTime
    go \
        -w ./architectures/net/mesh_8x16_CAMON.txt \
        --sampling-rate 10 \
        --mtsyn ./applications/shalom/aarch64/splash/cholesky/128.txt \
        -O ${RESULT_ROOT}/CHOLESKY_${proto}_CAMON_128_${comment}.txt \
        --g_LaserBank_config_file ./network/jade-wzh/LaserBank/config/LaserBank1e3Config.yaml \
        --g_JADE_E_NETWORK 0 \
        --g_JADE_CAMON_NETWORK 1 \
        \| tee ${LOG_ROOT}/cholesky_${proto}_128_${comment}_$(date +"%Y%m%d-%H%M").log 2>&1

    comment=WithLaserBank-5e3psKeepAliveTime
    go \
        -w ./architectures/net/mesh_8x16_CAMON.txt \
        --sampling-rate 10 \
        --mtsyn ./applications/shalom/aarch64/splash/cholesky/128.txt \
        -O ${RESULT_ROOT}/CHOLESKY_${proto}_CAMON_128_${comment}.txt \
        --g_LaserBank_config_file ./network/jade-wzh/LaserBank/config/LaserBank5e3Config.yaml \
        --g_JADE_E_NETWORK 0 \
        --g_JADE_CAMON_NETWORK 1 \
        \| tee ${LOG_ROOT}/cholesky_${proto}_128_${comment}_$(date +"%Y%m%d-%H%M").log 2>&1

    comment=WithLaserBank-1e4psKeepAliveTime
    go \
        -w ./architectures/net/mesh_8x16_CAMON.txt \
        --sampling-rate 10 \
        --mtsyn ./applications/shalom/aarch64/splash/cholesky/128.txt \
        -O ${RESULT_ROOT}/CHOLESKY_${proto}_CAMON_128_${comment}.txt \
        --g_LaserBank_config_file ./network/jade-wzh/LaserBank/config/LaserBank1e4Config.yaml \
        --g_JADE_E_NETWORK 0 \
        --g_JADE_CAMON_NETWORK 1 \
        \| tee ${LOG_ROOT}/cholesky_${proto}_128_${comment}_$(date +"%Y%m%d-%H%M").log 2>&1

    comment=WithLaserBank-5e4psKeepAliveTime
    go \
        -w ./architectures/net/mesh_8x16_CAMON.txt \
        --sampling-rate 10 \
        --mtsyn ./applications/shalom/aarch64/splash/cholesky/128.txt \
        -O ${RESULT_ROOT}/CHOLESKY_${proto}_CAMON_128_${comment}.txt \
        --g_LaserBank_config_file ./network/jade-wzh/LaserBank/config/LaserBank5e4Config.yaml \
        --g_JADE_E_NETWORK 0 \
        --g_JADE_CAMON_NETWORK 1 \
        \| tee ${LOG_ROOT}/cholesky_${proto}_128_${comment}_$(date +"%Y%m%d-%H%M").log 2>&1

    comment=WithLaserBank-1e5psKeepAliveTime
    go \
        -w ./architectures/net/mesh_8x16_CAMON.txt \
        --sampling-rate 10 \
        --mtsyn ./applications/shalom/aarch64/splash/cholesky/128.txt \
        -O ${RESULT_ROOT}/CHOLESKY_${proto}_CAMON_128_${comment}.txt \
        --g_LaserBank_config_file ./network/jade-wzh/LaserBank/config/LaserBank1e5Config.yaml \
        --g_JADE_E_NETWORK 0 \
        --g_JADE_CAMON_NETWORK 1 \
        \| tee ${LOG_ROOT}/cholesky_${proto}_128_${comment}_$(date +"%Y%m%d-%H%M").log 2>&1

    comment=WithLaserBank-5e5psKeepAliveTime
    go \
        -w ./architectures/net/mesh_8x16_CAMON.txt \
        --sampling-rate 10 \
        --mtsyn ./applications/shalom/aarch64/splash/cholesky/128.txt \
        -O ${RESULT_ROOT}/CHOLESKY_${proto}_CAMON_128_${comment}.txt \
        --g_LaserBank_config_file ./network/jade-wzh/LaserBank/config/LaserBank5e5Config.yaml \
        --g_JADE_E_NETWORK 0 \
        --g_JADE_CAMON_NETWORK 1 \
        \| tee ${LOG_ROOT}/cholesky_${proto}_128_${comment}_$(date +"%Y%m%d-%H%M").log 2>&1

    comment=WithLaserBank-1e6psKeepAliveTime
    go \
        -w ./architectures/net/mesh_8x16_CAMON.txt \
        --sampling-rate 10 \
        --mtsyn ./applications/shalom/aarch64/splash/cholesky/128.txt \
        -O ${RESULT_ROOT}/CHOLESKY_${proto}_CAMON_128_${comment}.txt \
        --g_LaserBank_config_file ./network/jade-wzh/LaserBank/config/LaserBank1e6Config.yaml \
        --g_JADE_E_NETWORK 0 \
        --g_JADE_CAMON_NETWORK 1 \
        \| tee ${LOG_ROOT}/cholesky_${proto}_128_${comment}_$(date +"%Y%m%d-%H%M").log 2>&1

}

goradix() {
    comment=WithLaserBank-1e4psKeepAliveTime
    go \
        -w ./architectures/net/mesh_8x16_CAMON.txt \
        --sampling-rate 10 \
        --mtsyn ./applications/shalom/aarch64/splash/radix/128.txt \
        -O ${RESULT_ROOT}/RADIX_${proto}_CAMON_128_${comment}.txt \
        --g_LaserBank_config_file ./network/jade-wzh/LaserBank/config/LaserBank1e4Config.yaml \
        --g_JADE_E_NETWORK 0 \
        --g_JADE_CAMON_NETWORK 1 \
        \| tee ${LOG_ROOT}/radix_${proto}_128_${comment}_$(date +"%Y%m%d-%H%M").log 2>&1

    comment=WithLaserBank-5e4psKeepAliveTime
    go \
        -w ./architectures/net/mesh_8x16_CAMON.txt \
        --sampling-rate 10 \
        --mtsyn ./applications/shalom/aarch64/splash/radix/128.txt \
        -O ${RESULT_ROOT}/RADIX_${proto}_CAMON_128_${comment}.txt \
        --g_LaserBank_config_file ./network/jade-wzh/LaserBank/config/LaserBank5e4Config.yaml \
        --g_JADE_E_NETWORK 0 \
        --g_JADE_CAMON_NETWORK 1 \
        \| tee ${LOG_ROOT}/radix_${proto}_128_${comment}_$(date +"%Y%m%d-%H%M").log 2>&1

    comment=WithLaserBank-1e5psKeepAliveTime
    go \
        -w ./architectures/net/mesh_8x16_CAMON.txt \
        --sampling-rate 10 \
        --mtsyn ./applications/shalom/aarch64/splash/radix/128.txt \
        -O ${RESULT_ROOT}/RADIX_${proto}_CAMON_128_${comment}.txt \
        --g_LaserBank_config_file ./network/jade-wzh/LaserBank/config/LaserBank1e5Config.yaml \
        --g_JADE_E_NETWORK 0 \
        --g_JADE_CAMON_NETWORK 1 \
        \| tee ${LOG_ROOT}/radix_${proto}_128_${comment}_$(date +"%Y%m%d-%H%M").log 2>&1

    comment=WithLaserBank-5e5psKeepAliveTime
    go \
        -w ./architectures/net/mesh_8x16_CAMON.txt \
        --sampling-rate 10 \
        --mtsyn ./applications/shalom/aarch64/splash/radix/128.txt \
        -O ${RESULT_ROOT}/RADIX_${proto}_CAMON_128_${comment}.txt \
        --g_LaserBank_config_file ./network/jade-wzh/LaserBank/config/LaserBank5e5Config.yaml \
        --g_JADE_E_NETWORK 0 \
        --g_JADE_CAMON_NETWORK 1 \
        \| tee ${LOG_ROOT}/radix_${proto}_128_${comment}_$(date +"%Y%m%d-%H%M").log 2>&1

    comment=WithLaserBank-1e6psKeepAliveTime
    go \
        -w ./architectures/net/mesh_8x16_CAMON.txt \
        --sampling-rate 10 \
        --mtsyn ./applications/shalom/aarch64/splash/radix/128.txt \
        -O ${RESULT_ROOT}/RADIX_${proto}_CAMON_128_${comment}.txt \
        --g_LaserBank_config_file ./network/jade-wzh/LaserBank/config/LaserBank1e6Config.yaml \
        --g_JADE_E_NETWORK 0 \
        --g_JADE_CAMON_NETWORK 1 \
        \| tee ${LOG_ROOT}/radix_${proto}_128_${comment}_$(date +"%Y%m%d-%H%M").log 2>&1

}

gofreqmine() {
    comment=WithLaserBank-1e4psKeepAliveTime
    go \
        -w ./architectures/net/mesh_8x16_CAMON.txt \
        --sampling-rate 10 \
        --mtsyn ./applications/shalom/aarch64/parsec/freqmine/128.txt \
        -O ${RESULT_ROOT}/FREQMINE_${proto}_CAMON_128_${comment}.txt \
        --g_LaserBank_config_file ./network/jade-wzh/LaserBank/config/LaserBank1e4Config.yaml \
        --g_JADE_E_NETWORK 0 \
        --g_JADE_CAMON_NETWORK 1 \
        \| tee ${LOG_ROOT}/freqmine_${proto}_128_${comment}_$(date +"%Y%m%d-%H%M").log 2>&1

    comment=WithLaserBank-5e4psKeepAliveTime
    go \
        -w ./architectures/net/mesh_8x16_CAMON.txt \
        --sampling-rate 10 \
        --mtsyn ./applications/shalom/aarch64/parsec/freqmine/128.txt \
        -O ${RESULT_ROOT}/FREQMINE_${proto}_CAMON_128_${comment}.txt \
        --g_LaserBank_config_file ./network/jade-wzh/LaserBank/config/LaserBank5e4Config.yaml \
        --g_JADE_E_NETWORK 0 \
        --g_JADE_CAMON_NETWORK 1 \
        \| tee ${LOG_ROOT}/freqmine_${proto}_128_${comment}_$(date +"%Y%m%d-%H%M").log 2>&1

    comment=WithLaserBank-1e5psKeepAliveTime
    go \
        -w ./architectures/net/mesh_8x16_CAMON.txt \
        --sampling-rate 10 \
        --mtsyn ./applications/shalom/aarch64/parsec/freqmine/128.txt \
        -O ${RESULT_ROOT}/FREQMINE_${proto}_CAMON_128_${comment}.txt \
        --g_LaserBank_config_file ./network/jade-wzh/LaserBank/config/LaserBank1e5Config.yaml \
        --g_JADE_E_NETWORK 0 \
        --g_JADE_CAMON_NETWORK 1 \
        \| tee ${LOG_ROOT}/freqmine_${proto}_128_${comment}_$(date +"%Y%m%d-%H%M").log 2>&1

    comment=WithLaserBank-5e5psKeepAliveTime
    go \
        -w ./architectures/net/mesh_8x16_CAMON.txt \
        --sampling-rate 10 \
        --mtsyn ./applications/shalom/aarch64/parsec/freqmine/128.txt \
        -O ${RESULT_ROOT}/FREQMINE_${proto}_CAMON_128_${comment}.txt \
        --g_LaserBank_config_file ./network/jade-wzh/LaserBank/config/LaserBank5e5Config.yaml \
        --g_JADE_E_NETWORK 0 \
        --g_JADE_CAMON_NETWORK 1 \
        \| tee ${LOG_ROOT}/freqmine_${proto}_128_${comment}_$(date +"%Y%m%d-%H%M").log 2>&1

    comment=WithLaserBank-1e6psKeepAliveTime
    go \
        -w ./architectures/net/mesh_8x16_CAMON.txt \
        --sampling-rate 10 \
        --mtsyn ./applications/shalom/aarch64/parsec/freqmine/128.txt \
        -O ${RESULT_ROOT}/FREQMINE_${proto}_CAMON_128_${comment}.txt \
        --g_LaserBank_config_file ./network/jade-wzh/LaserBank/config/LaserBank1e6Config.yaml \
        --g_JADE_E_NETWORK 0 \
        --g_JADE_CAMON_NETWORK 1 \
        \| tee ${LOG_ROOT}/freqmine_${proto}_128_${comment}_$(date +"%Y%m%d-%H%M").log 2>&1

}

go_nas_lu() {
    go \
        -w ./architectures/net/mesh_8x16_CAMON.txt \
        --sampling-rate 10 \
        --mtsyn ./applications/shalom/aarch64/nas/lu/128.txt \
        -O ${RESULT_ROOT}/NASLU_${proto}_CAMON_128_${comment}.txt \
        \| tee ${LOG_ROOT}/naslu_${proto}_128_${comment}_$(date +"%Y%m%d-%H%M").log 2>&1

}

go_nas_ft() {
    go \
        -w ./architectures/net/mesh_8x16_CAMON.txt \
        --sampling-rate 10 \
        --mtsyn ./applications/shalom/aarch64/nas/ft/128.txt \
        -O ${RESULT_ROOT}/NASFT_${proto}_CAMON_128_${comment}.txt \
        \| tee ${LOG_ROOT}/nasft_${proto}_128_${comment}_$(date +"%Y%m%d-%H%M").log 2>&1

}

go_nas_mg() {
    go \
        -w ./architectures/net/mesh_8x16_CAMON.txt \
        --sampling-rate 10 \
        --mtsyn ./applications/shalom/aarch64/nas/mg/128.txt \
        -O ${RESULT_ROOT}/NASMG_${proto}_CAMON_128_${comment}.txt \
        \| tee ${LOG_ROOT}/nasmg_${proto}_128_${comment}_$(date +"%Y%m%d-%H%M").log 2>&1
}

goall() {
    # gofft
    gofft_simple
    # golu
    golu_simple
    # govolrend
    # gobarnes
    # gowater-spatial  # problematic benchmark
    # gofmm
    gocholesky
    # gocholesky_simple
    # goradix
    # gofreqmine
    # go_nas_lu
    # go_nas_ft
    # go_nas_mg
}

key_word="."
cmd=""
[ ! -z "$1" ] && key_words="${@}"
for key_word in $key_words; do
    echo $key_word
    # non-interactive fzf with exact match
    temp_cmd=$(goall | fzf --exact --filter "${key_word/:/ }")
    [ ! -z "$temp_cmd" ] && cmd+=$temp_cmd && cmd+=$'\n'
done
# Remove the redundant new line
cmd=$(echo "$cmd" | sed -e '$ d')
# Check if the command is empty
[ -z "$cmd" ] && echo "Cannot find a command to run. Exit." && exit
# Count the number of commands to run
num_command=$(echo "$cmd" | wc -l)
# The double quote here is needed to keep the multiline format. -E extended regex
echo "$cmd" | sed -e "s/^/\>\> /g" | sed -e "s/$/\n/g" | sed -E -e "s/( -| \|)/\n\t&/g"

echo -n "Execute $num_command commands with $NUM_PROC threads? "
echo -n "But please mind the memory usage. [Y/n] "
read user_input
[ ! "$user_input" = 'Y' ] && echo "User cancelled" && exit
unset $user_input

# start running
echo "$cmd" | xargs -P$NUM_PROC -i bash -c "{}"
# echo "$cmd"
