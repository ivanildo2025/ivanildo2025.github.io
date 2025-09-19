#!/bin/bash



# Verifica se o script está sendo executado como root

if [ "$EUID" -ne 0 ]; then

    echo "Este script deve ser executado como root" >&2

    exit 1

fi



# Verifica espaço em disco

echo "Verificando espaço em disco..."

df -h /



# Verifica pacotes em espera

echo "Verificando pacotes em espera..."

apt-mark showhold



# Atualiza listas de pacotes

apt update 2>&1 | tee -a upgrade.log



# Faz backup das fontes

cp /etc/apt/sources.list /etc/apt/sources.list.bookworm-backup

cp -r /etc/apt/sources.list.d /etc/apt/sources.list.d.bookworm-backup



# Modifica as fontes para Trixie

sed -i 's/bookworm/trixie/g' /etc/apt/sources.list

find /etc/apt/sources.list.d -name "*.list" -exec sed -i 's/bookworm/trixie/g' {} \;



# Exibe as fontes modificadas para verificação

echo "Fontes modificadas em sources.list:"

cat /etc/apt/sources.list

echo "Fontes modificadas em sources.list.d:"

cat /etc/apt/sources.list.d/*.list



# Atualiza listas de pacotes novamente

apt update 2>&1 | tee -a upgrade.log



# Realiza a atualização completa

apt full-upgrade 2>&1 | tee -a upgrade.log



# Limpa pacotes desnecessários

apt autoremove 2>&1 | tee -a upgrade.log

apt autoclean 2>&1 | tee -a upgrade.log



# Verifica a versão do sistema

echo "Versão do sistema após a atualização:"

cat /etc/debian_version

lsb_release -a

cat /etc/os-release



# Lista pacotes atualizáveis (opcional)

apt list --upgradable



# Avisa sobre a reinicialização

echo "O sistema será reiniciado em 10 segundos. Pressione Ctrl+C para cancelar."

sleep 10

systemctl reboot
