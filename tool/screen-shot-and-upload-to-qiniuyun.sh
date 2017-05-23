#!/bin/bash
#使用xfce4-screenshooter截图并保存到文件，上传到七牛云。
#依赖工具：xfce4-screenshooter/xclip/qshell/qrencode
#需要配置qshell的AccessKey/SecretKey，见文档https://github.com/qiniu/qshell/blob/master/README.md#密钥设置

#截图，复制到系统剪贴板
xfce4-screenshooter -rc
#七牛空间名称，可以为公开空间或私有空间
bucket={七牛空间名称}
#域名
site={七牛云域名}
#文件名
filename=$(date +"scrnst%Y%m%d%H%M%S.png")
#保存目录
path={截图文件保存目录}
#文件路径
filepath=$path$filename
#将系统剪贴板中的图片保存到家目录
xclip -selection clipboard -target image/png -out > $filepath
#上传到七牛云
qshell fput image $filename $filepath
#打印信息
echo 
#在终端输出二维码
echo "QR:"
qrencode -m 2 -o - $site$filename -t UTF8
echo "Image URL:"
echo $site$filename
echo "Markdown code:"
echo ![$filename]\($site$filename\)