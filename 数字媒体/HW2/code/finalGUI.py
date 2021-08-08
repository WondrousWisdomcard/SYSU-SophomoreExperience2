from tkinter import *
from tkinter.filedialog import askopenfilename
from time import *
from matplotlib import pyplot as plt
from PIL import Image, ImageTk

import cv2
import numpy as np
from scipy import stats

filename_1 = '../image/7-1.jpg'
filename_2 = '../image/7-2.jpg'
bg_color = 'white'

def getHistogram(image, v, c):
    color = ('blue', 'green', 'red')
    for i , color in enumerate(color):
        hist = cv2.calcHist([image], [i], None, [256], [0, 256])    
        plt.plot(hist, color, linestyle = v, label = 'Image' + str(c+1) + '-' + color)
        plt.xlim([0, 256])
        plt.legend()

def checkColorgram():
    src1 = cv2.imread(filename_1)
    src2 = cv2.imread(filename_2)
    getHistogram(src1, ':', 0)
    getHistogram(src2, '-', 1)
    plt.show()

def getVector(img_file):  
    img = cv2.imread(img_file)
    img_rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB) # cv2默认为bgr顺序
    h, w, n = img_rgb.shape #返回height，width，以及通道数，不用所以省略掉
    
    print('getVector：图片信息 ',img_file,' 行数：%d，列数：%d，通道数：%d' % (h, w, n))

    arr = np.zeros((4,4,4))
    farr = np.zeros(64)

    for img_line in img_rgb:
        for img_cell in img_line:
            a = img_cell[0] // 64
            b = img_cell[1] // 64
            c = img_cell[2] // 64
            arr[a][b][c] = arr[a][b][c] + 1
 
    for i in range(4):
        for j in range(4):
            for k in range(4):
                farr[i*16+j*4+k] = arr[i][j][k]
    
    return farr

def getPearson():
    print('getPearson: 图片-1 ', filename_1)
    print('getPearson: 图片-2 ', filename_2)
    # 64个元素的向量
    farr_1 = getVector(filename_1)
    farr_2 = getVector(filename_2)
    # print("Image1:",farr_1)
    # print("Image2:",farr_2)

    # 计算相关系数        
    pearson_val = stats.pearsonr(farr_1, farr_2)
    res = abs(pearson_val[0]*100)
    strin = (" Image Similarity: %.02f" % (res) + "% ")
    print("getPearson:" +strin)
    return strin

# 相关系数 
# 0.8-1.0 极强相关
# 0.6-0.8 强相关
# 0.4-0.6 中等程度相关
# 0.2-0.4 弱相关
# 0.0-0.2 极弱相关或无相关

class App(Frame):
    def chooseFile_1(self):
        global filename_1
        filename = askopenfilename(title='Please choose a file', initialdir='/', filetypes=[('Image file','*.jpg')])
        filename_1 = filename_1.replace(filename_1, filename)
        print(filename_1)

        self.photo = Image.open(filename_1)  
        self.photo = self.photo.resize((int(self.photo.width / self.photo.height * 200), 200))
        self.img_1 = ImageTk.PhotoImage(self.photo)
        self.photo_frame1 = Label(self, image = self.img_1, bg = bg_color)
        self.photo_frame1.grid(row = 4, column = 0, sticky = N)

    def chooseFile_2(self):
        global filename_2
        filename = askopenfilename(title='Please choose a file', initialdir='/', filetypes=[('Image file','*.jpg')])
        filename_2 = filename_2.replace(filename_2, filename)
        print(filename_2)

        self.photo = Image.open(filename_2)  
        self.photo = self.photo.resize((int(self.photo.width / self.photo.height * 200), 200))
        self.img_2 = ImageTk.PhotoImage(self.photo)
        self.photo_frame2 = Label(self, image = self.img_2, bg = bg_color)
        self.photo_frame2.grid(row = 4, column = 1, sticky = N)

    def computingPearson(self):
        strin = getPearson()
        self.pearson_label = Label(self, text= strin, fg='black', font=("Impact",30), relief = RAISED)
        self.pearson_label.grid(row = 8, columnspan = 2, sticky = N)

    def createWidgets(self):

        self.title_label = Label(self, text='Image Similarity Calculation', fg='black', font=("Impact",30))
        self.title_label.grid(row = 0, columnspan = 2, sticky = N)

        self.line_1 = Label(self, text=' ', font=("Impact",10))
        self.line_1.grid(row = 1, columnspan = 2, sticky = N)

        self.button_1 = Button(self, text = '   Choose Image-1   ', font=("Impact"), command = self.chooseFile_1)
        self.button_1.grid(row = 2, column = 0, sticky = N)

        self.button_2 = Button(self, text = '   Choose Image-2   ', font=("Impact"), command = self.chooseFile_2)
        self.button_2.grid(row = 2, column = 1, sticky = N)

        self.line_2 = Label(self, text=' ', font=("Impact",10))
        self.line_2.grid(row = 3, columnspan = 2, sticky = N)

        self.photo = Image.open(filename_1)  
        self.photo = self.photo.resize((int(self.photo.width / self.photo.height * 200), 200))
        self.img_1 = ImageTk.PhotoImage(self.photo)
        self.photo_frame1 = Label(self, image = self.img_1)
        self.photo_frame1.grid(row = 4, column = 0, sticky = N)

        self.photo = Image.open(filename_2)  
        self.photo = self.photo.resize((int(self.photo.width / self.photo.height * 200), 200))
        self.img_2 = ImageTk.PhotoImage(self.photo)
        self.photo_frame2 = Label(self, image = self.img_2)
        self.photo_frame2.grid(row = 4, column = 1, sticky = N)

        self.line_3 = Label(self, text=' ', font = ("Impact",10))
        self.line_3.grid(row = 5, columnspan = 2, sticky = N)

        self.pearson_button = Button(self, text = '     Start Computing!     ', font = ("Impact", 20), command = self.computingPearson)
        self.pearson_button.grid(row = 6, columnspan = 2, sticky = N)

        self.info_1 = Label(self, text='对于较大图像，计算时间在30秒到1分钟之间', fg = 'black', font = ("Impact",10))
        self.info_1.grid(row = 7, columnspan = 2, sticky = N)

        self.pearson_label = Label(self, text= " Image Similarity: ??% ", fg = 'black', font = ("Impact", 30))
        self.pearson_label.grid(row = 8, columnspan = 2, sticky = N)

        self.info_2 = Label(self, text='0% - 极弱相关或无相关 - 20% - 弱相关 - 40% - 中等程度相关 - 60% - 强相关 - 80% - 极强相关 - 100%', fg = 'black', font = ("Impact", 10))
        self.info_2.grid(row = 9, columnspan = 2, sticky = N)

        self.line_4 = Label(self, text=' ', font=("Impact",10))
        self.line_4.grid(row = 10, columnspan = 2, sticky = N)

        self.pearson_button = Button(self, text = '   Generate Color Histogram   ', fg = 'black', font = ("Impact", 15), command = checkColorgram)
        self.pearson_button.grid(row = 11, columnspan = 2, sticky = N)
    
    def __init__(self, master=None):
        Frame.__init__(self, master)
        self.pack()
        self.createWidgets()

root = Tk()
root.title('Jojo! Image Similarity Calculation')
root.geometry('900x650')
app = App(master = root)
app.mainloop()
root.destroy()
