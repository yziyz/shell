#!/bin/bash
#使用xfce4-screenshooter截图并保存到文件，上传到阿里云OSS。
#依赖工具：xfce4-screenshooter/xclip/ossutil/qrencode
#需要配置accessKeyID/accessKeySecret/，见文档https://help.aliyun.com/document_detail/50452.html?spm=5176.doc50561.6.1020.NBEbO3

#截图，复制到系统剪贴板
xfce4-screenshooter -rc
#OSSbucket
bucket={bucket名称，如"oss://mybucket01"}
#域名
site={OSS域名，例如"http://mybucket01.oss-cn-shanghai.aliyuncs.com"}
#截图文件名
filename=$(date +"scrnst%Y%m%d%H%M%S.png")
#截图保存目录
path=~/
#文件路径
filepath=$path$filename
#将系统剪贴板中的图片保存到家目录
xclip -selection clipboard -target image/png -out > $filepath
#上传到七牛云
ossutil cp $filepath $bucket
#打印信息
echo 
#在终端输出二维码
echo "QR:"
qrencode -m 2 -o - $site$filename -t UTF8
echo "Image URL:"
echo $site$filename
echo "Markdown code:"
echo ![$filename]\($site$filename\)