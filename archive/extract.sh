#!/usr/bin/env bash
#//////////////////////////////////////////////////////////////
#//   ____                                                   //
#//  | __ )  ___ _ __  ___ _   _ _ __   ___ _ __ _ __   ___  //
#//  |  _ \ / _ \ '_ \/ __| | | | '_ \ / _ \ '__| '_ \ / __| //
#//  | |_) |  __/ | | \__ \ |_| | |_) |  __/ |  | |_) | (__  //
#//  |____/ \___|_| |_|___/\__,_| .__/ \___|_|  | .__/ \___| //
#//                             |_|             |_|          //
#//////////////////////////////////////////////////////////////
#//                                                          //
#//  Script, 2021                                            //
#//  Created: 28, May, 2021                                  //
#//  Modified: 24, July, 2021                                //
#//  file: -                                                 //
#//  -                                                       //
#//  Source: https://www.quora.com/What-is-the-most-useful-bash-script-that-you-have-ever-written //
#//          https://wiki.archlinux.org/title/Archiving_and_compression
#//          https://github.com/xvoland/Extract              //
#//          https://raw.githubusercontent.com/rawiriblundell/dotfiles/master/.bashrc //
#//  OS: ALL                                                 //
#//  CPU: ALL                                                //
#//                                                          //
#//////////////////////////////////////////////////////////////

if (( $# == 0 )); then
    printf -- '%s\n' "${0}: No arguments provided" 
        "Usage: extract <file1> <file2>" >&2
    exit 1
fi

rc=0
for fsobj; do
    xcmd=''

    if [[ ! -r ${fsobj} ]]; then
        printf -- '%s\n' "${0}: file is unreadable: '${fsobj}'" >&2
        continue
    fi

    [[ -e ./"${fsobj#/}" ]] && fsobj="./${fsobj#/}"

    case ${fsobj} in
        (*.tar.lz)    xcmd=(lzip -d) ;; #tar --lzip -tf $1   ;;
        (*.tar.7z)
            7z x -so "${fsobj}" | tar -xf -
            rc=$(( rc + "${?}" ))
            continue
        ;;
        (*.tar.Z)
            zcat "${fsobj}" | tar -xvf -
            rc=$(( rc + "${?}" ))
            continue
        ;; 
        (*.cbt|*.t@(gz|lz|xz|b@(2|z?(2))|a@(z|r?(.@(Z|bz?(2)|gz|lzma|xz)))))
            case "${fsobj}" in
                (*.cbt|*.tar)       taropts=( xvf ) ;;
                (*.tar.bz2|*.tbz2)  taropts=( xvjf ) ;; 
                (*.tar.gz|*.tgz)    taropts=( xvzf ) ;; 
                (*.tar.lzma)        taropts=( --lzma -xvf ) ;; 
                (*.tar.xz)          taropts=( -xf ) ;; 
            esac
            xcmd=(tar "${taropts[@]}")
        ;;
        (*.7z*|*.apk|*.arj|*.cab|*.chm|*.deb|*.dmg|*.iso|*.lzh|*.msi|*.pkg|*.rpm|*.udf|*.wim|*.xar)
            xcmd=(7z x)
        ;;
        (*.ace|*.cba)         xcmd=(unace x) ;;
        (*.arc|*.ark)         xcmd=(arc e) ;;
        (*.cbr|*.rar)         xcmd=(unrar x) ;;
        (*.cbz|*.epub|*.zip)  xcmd=(unzip) ;;
        (*.cpio)
            cpio -id < "${fsobj}"
            rc=$(( rc + "${?}" ))
            continue
        ;;
        (*.cso)
            ciso 0 "${fsobj}" "${fsobj}".iso
            extract "${fsobj}".iso
            rm -rf "${fsobj:?}"; rc=$(( rc + "${?}" ))
            continue
        ;;
        (*.bz2)   xcmd=(bunzip2) ;;
        (*.exe)   xcmd=(cabextract) ;;
        (*.gz)    xcmd=(gunzip) ;;
        (*.jar)   xcmd=(jar xf) ;;
        (*.lz4)   xcmd=(lz4 -d) ;; 
        (*.lzma)  xcmd=(unlzma) ;;
        (*.xz)    xcmd=(unxz) ;;
        (*.Z|*.z) xcmd=(uncompress) ;;
        (*.zpaq)  xcmd=(zpaq x) ;;
        (*.zoo)   xcmd=(zoo -extract) ;; 
        (*.zst)   xcmd=(zstd -dc) ;; 
        (*)
            printf -- '%s\n' "${0}: unrecognized file extension: '${fsobj}'" >&2
            continue
        ;;
    esac

    command "${xcmd[@]}" "${fsobj}"
    rc=$(( rc + "${?}" ))
done
(( rc > 0 )) && exit "${rc}"
exit 0
