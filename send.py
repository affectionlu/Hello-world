#!/usr/bin/env python  
# encoding: utf-8 

""" 
@author: payneLi  
@time: 18-7-9 下午10:34
@email: lph0729@163.com  

"""
from socket import *
import cv2
import time
import numpy as np
import struct


class SocketClient(object):
    def __init__(self):
        self.TargetIP = ("127.0.0.1", 8001)
        self.resolution = (680, 480)
        self.img_fps = 60  # send picture each second
        self.socket_client = socket(AF_INET, SOCK_STREAM)
        self.socket_client.connect(self.TargetIP)
        self.img = ""
        self.img_data = ""

    def rt_image(self):
        # opencv自带的VideoCapture()函数定义摄像头对象，其参数0表示第一个摄像头，一般就是笔记本的内建摄像头
        camera = cv2.VideoCapture(1)
        img_param = [int(cv2.IMWRITE_JPEG_CHROMA_QUALITY), self.img_fps]
        while True:
            #time.sleep(0.1)
            _, self.img = camera.read()
            self.img = cv2.resize(self.img, self.resolution)
            _, img_encode = cv2.imencode(".jpg", self.img, img_param)
            img_code = np.array(img_encode)
            self.img_data = img_code.tostring()  # bytes data

            try:
                packet = struct.pack("lhh", len(self.img_data), self.resolution[0], self.resolution[1])
                self.socket_client.send(packet)
                self.socket_client.send(self.img_data)
            except Exception as e:
                print(e.args)
                camera.release()
                return


if __name__ == '__main__':
    client = SocketClient()
    client.rt_image()
