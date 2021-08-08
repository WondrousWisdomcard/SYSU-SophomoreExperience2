from tkinter import *
from time import *
from tkinter.filedialog import askopenfilename
from PIL import Image, ImageTk
import os
import cv2

from detect import face_selection
from convert import face_swap

# Global Variable
u_font = "Verdana"
Tutorial = "Tutorial\n\n" \
           "Introduction\n" \
           "This App can achieve swapping Face into Image A into Media B, B can be image(.jpg, .png) " \
           "or video(.mp4, .avi)\n" \
           "You will see the generated media on the right frame, and it will be saved in the directory " \
           "'./out'.\n" \
           "Generate an image will cost approximately 1 second, about a video, it depends on the " \
           "frames of video.\n\n" \
           "How To Use\n" \
           "1. Click 'Select Image A' to choose Image A\n" \
           "2. Click 'Select Media B' to choose Media A\n" \
           "3. Choose warp mode: 3D is better and highly recommended\n" \
           "4. Choose color correct mode: using it is better\n" \
           "5. Click 'Convert' to swap face, it take times\n" \
           "6. Result will be showed in the third image frame, and it will be save to ./out\n\n" \
           "Notice \nWhen generating video, the interface will be blocked," \
           " don't change any selection and be patient!\n\n" \
           "Developer Information \nWondrouswisdomcard\n\n" \
           "Reference code \nhttps://github.com/wuhuikai/FaceSwap.git\n"

flag2 = 0
flag3 = 0
GlobalImageAPath = ""
GlobalMediaBPath = ""
GlobalColorCorrect = 0
Global3DWarp = 1
ImageSize = 180

root = Tk()
root.title('F A C E  S W A P')
root.geometry('885x500')

filename = "./image/interface.jpg"
Photo1 = Image.open(filename)
Photo1 = Photo1.resize((ImageSize, int(Photo1.height / Photo1.width * ImageSize)))
Img1 = ImageTk.PhotoImage(Photo1)

class VideoHandler(object):
    def __init__(self, ImageAPath, MediaBPath, FilePath, ColorCorrect, Warp):
        ImageA = cv2.imread(ImageAPath)
        Terminal.insert("insert", "> Start face detection...\n")
        Terminal.see(END)
        self.SrcPoints, self.SrcShape, self.SrcFace = face_selection(ImageA)
        if self.SrcPoints is None:
            Terminal.insert("insert", "> [Error] Unable to access image A\n")
            Terminal.see(END)
            return

        self.Video = cv2.VideoCapture(MediaBPath)
        if self.Video is None:
            Terminal.insert("insert", "> [Error] Unable to access video B\n")
            Terminal.see(END)
            return
        self.width = int(self.Video.get(cv2.CAP_PROP_FRAME_WIDTH))
        self.height = int(self.Video.get(cv2.CAP_PROP_FRAME_HEIGHT))
        self.Writer = cv2.VideoWriter(FilePath, cv2.VideoWriter_fourcc(*'MJPG'), self.Video.get(cv2.CAP_PROP_FPS),
                                      (self.width, self.height))

    def start(self):
        j = 0
        Terminal.insert("insert", "> Start face swap, it might take a long time...\n")
        Terminal.see(END)
        sleep(1)

        FrameNum = self.Video.get(7)
        print(FrameNum)

        i = 0
        while True:
            i = i + 1
            if i == FrameNum:
                break

            ret, TempImg = self.Video.read()
            TempPoints, TempShape, TempFace = face_selection(TempImg)
            if TempPoints is not None:
                ResImg = face_swap(self.SrcFace, TempFace, self.SrcPoints, TempPoints, TempShape, TempImg, Global3DWarp, GlobalColorCorrect)
                self.Writer.write(ResImg)
            else:
                self.Writer.write(TempImg)
            print(i)

        self.Video.release()
        self.Writer.release()
        #cv2.destroyAllWindows()
        Terminal.insert("insert", "> Face swap finish...\n")
        Terminal.see(END)

# Command Function Area

def getTimeStr():
    return strftime("FaceSwap-%m%d%H%M%S", localtime())

def FaceSwap():
    global GlobalImageAPath, GlobalMediaBPath, GlobalColorCorrect, Global3DWarp

    Terminal.insert("insert", "> Start to convert...\n")
    Terminal.insert("insert", "+ Convert Arguments\n")
    Terminal.insert("insert", "| Image A Path: " + GlobalImageAPath + "\n")
    Terminal.insert("insert", "| Media B Path: " + GlobalMediaBPath + "\n")
    if Global3DWarp:
        Terminal.insert("insert", "| Face Warping: 3D\n")
    else:
        Terminal.insert("insert", "| Face Warping: 2D\n")

    if GlobalColorCorrect:
        Terminal.insert("insert", "| Color correction: Active\n")
    else:
        Terminal.insert("insert", "| Color correction: Inactive\n")
    Terminal.see(END)

    if len(GlobalImageAPath) == 0:
        Terminal.insert("insert", "> [Error] Unable to access image A\n")
        Terminal.see(END)
        return None

    if len(GlobalMediaBPath) == 0:
        Terminal.insert("insert", "> [Error] Unable to access media B\n")
        Terminal.see(END)
        return None

    SrcImg = cv2.imread(GlobalImageAPath)
    if SrcImg is None:
        Terminal.insert("insert", "> [Error] Unable to access image A\n")
        Terminal.see(END)
        return None

    if GlobalMediaBPath[-3:] == 'jpg' or GlobalMediaBPath[-3:] == 'png':
        DstImg = cv2.imread(GlobalMediaBPath)
        if DstImg is None:
            Terminal.insert("insert", "> [Error] Unable to access media B\n")
            Terminal.see(END)
            return None

        Terminal.insert("insert", "> Start face detection...\n")
        Terminal.see(END)
        SrcPoints, SrcShape, SrcFace = face_selection(SrcImg)
        DstPoints, DstShape, DstFace = face_selection(DstImg)

        if SrcPoints is None:
            Terminal.insert("insert", "> [Error] Detected 0 face on image A\n")
            Terminal.see(END)
            return None
        if DstPoints is None:
            Terminal.insert("insert", "> [Error] Detected 0 face on image B\n")
            Terminal.see(END)
            return None

        Terminal.insert("insert", "> Start face swap...\n")
        Terminal.see(END)
        output = face_swap(SrcFace, DstFace, SrcPoints, DstPoints, DstShape, DstImg, Global3DWarp, GlobalColorCorrect, end = 48)
        DirPath = "./out"
        FileName = getTimeStr() + ".jpg"
        FilePath = DirPath + "/" + FileName

        if not os.path.isdir(DirPath):
            os.makedirs(DirPath)

        cv2.imwrite(FilePath, output)

        p = Image.open(FilePath)
        if p.height > p.width:
            p = p.resize((ImageSize, int(p.height / p.width * ImageSize)))
        else:
            p = p.resize((int(p.width / p.height * ImageSize),ImageSize))
        i = ImageTk.PhotoImage(p)
        Photo3.config(image = i)
        Photo3.image = i
        Terminal.insert("insert", "> Face swap finish!\n")
        Terminal.see(END)

    elif GlobalMediaBPath[-3:] == 'mp4' or GlobalMediaBPath[-3:] == 'avi':
        DirPath = "./out"
        FileName = getTimeStr() + ".avi"
        FilePath = DirPath + "/" + FileName

        if not os.path.isdir(DirPath):
            os.makedirs(DirPath)

        Handler = VideoHandler(GlobalImageAPath, GlobalMediaBPath, FilePath, GlobalColorCorrect, Global3DWarp)
        Handler.start()

        def start(event):
            global flag3
            if flag3 == 1:
                flag3 = 0
                VideoButton3.config(text='Res Continue')
                VideoButton3.update()
            else:
                flag3 = 1
                VideoButton3.config(text='Res Stop')
                VideoButton3.update()
            video_loop(video)

        f = FilePath
        VideoButton3.config(text='Res Show')
        VideoButton3.update()
        video = cv2.VideoCapture(f)
        WaitTime = 1000 / video.get(5)

        def video_loop(video):
            global flag3
            ret, frame = video.read()
            if ret:
                img = cv2.cvtColor(frame, cv2.COLOR_BGR2RGBA)
                p = Image.fromarray(img)
                if p.height > p.width:
                    p = p.resize((ImageSize, int(p.height / p.width * ImageSize)))
                else:
                    p = p.resize((int(p.width / p.height * ImageSize), ImageSize))
                imgtk = ImageTk.PhotoImage(image=p)
                Photo3.imgtk = imgtk
                Photo3.config(image=imgtk)
                if flag3 == 1:
                    PhotoFrame3.after(int(WaitTime), lambda: video_loop(video))
            else:
                VideoButton3.config(text='Result Video')
                VideoButton3.update()

        VideoButton3.bind("<ButtonRelease-1>", start)

        flag3 = 0
        video_loop(video)

def SetColorCorrect():
    global GlobalColorCorrect
    GlobalColorCorrect = 1
    Terminal.insert("insert", "> Color correction: Active\n")
    Terminal.see(END)

def ResetColorCorrect():
    global GlobalColorCorrect
    GlobalColorCorrect = 0
    Terminal.insert("insert", "> Color correction: Inactive\n")
    Terminal.see(END)

def Set3DWarp():
    global Global3DWarp
    Global3DWarp = 1
    Terminal.insert("insert", "> Face Warping: 3D\n")
    Terminal.see(END)

def Set2DWarp():
    global Global3DWarp
    Global3DWarp = 0
    Terminal.insert("insert", "> Face Warping: 2D\n")
    Terminal.see(END)

def ChooseFileA():
    global GlobalImageAPath
    f = askopenfilename(title='Please choose an image', initialdir='/', filetypes=[('Image file', ('*.jpg','*.png'))])
    GlobalImageAPath = f
    p = Image.open(f)
    if p.height > p.width:
        p = p.resize((ImageSize, int(p.height / p.width * ImageSize)))
    else:
        p = p.resize((int(p.width / p.height * ImageSize), ImageSize))
    i = ImageTk.PhotoImage(p)
    Photo1.config(image = i)
    Photo1.image = i
    Terminal.insert("insert", "> Choose Picture " + f + " as Image A\n")
    Terminal.see(END)

def ChooseFileB():
    global flag2, GlobalMediaBPath
    f = askopenfilename(title='Please choose a media', initialdir='/', filetypes=[('Media file', ('*.jpg','*.png','*.mp4','*.avi'))])
    GlobalMediaBPath = f
    def start(event):
        global flag2
        if flag2 == 1:
            flag2 = 0
            VideoButton2.config(text='B Continue')
            VideoButton2.update()
        else:
            flag2 = 1
            VideoButton2.config(text='B Stop')
            VideoButton2.update()
        video_loop(video)

    if f[-3:] == 'jpg' or f[-3:] == 'png':
        p = Image.open(f)
        if p.height > p.width:
            p = p.resize((ImageSize, int(p.height / p.width * ImageSize)))
        else:
            p = p.resize((int(p.width / p.height * ImageSize), ImageSize))
        i = ImageTk.PhotoImage(p)
        Photo2.config(image = i)
        Photo2.image = i
        Terminal.insert("insert", "> Choose Image " + f + " as Media B\n")
        Terminal.see(END)

        VideoButton2.unbind(0)

    elif f[-3:] == 'mp4' or f[-3:] == 'avi':
        VideoButton2.config(text='B Start')
        VideoButton2.update()
        video = cv2.VideoCapture(f)
        Terminal.insert("insert", "> Choose Video " + f + " as Media B\n")
        Terminal.see(END)
        WaitTime = 1000 / video.get(5)

        def video_loop(video):
            global flag2
            ret, frame = video.read()
            if ret:
                img = cv2.cvtColor(frame, cv2.COLOR_BGR2RGBA)
                p = Image.fromarray(img)
                if p.height > p.width:
                    p = p.resize((ImageSize, int(p.height / p.width * ImageSize)))
                else:
                    p = p.resize((int(p.width / p.height * ImageSize), ImageSize))
                imgtk = ImageTk.PhotoImage(image=p)
                Photo2.imgtk = imgtk
                Photo2.config(image=imgtk)
                if flag2 == 1:
                    PhotoFrame2.after(int(WaitTime), lambda: video_loop(video))
            else:
                VideoButton2.config(text='B')
                VideoButton2.update()

        VideoButton2.bind("<ButtonRelease-1>", start)

        flag2 = 0
        video_loop(video)

# Head Frame
HeadFrame = Frame(root, relief = "solid", bd = 1, bg = "White")
Header = Label(HeadFrame, text = " F A C E  S W A P ", font = (u_font, 20), width = 50, anchor = "w", bg = "White")
Header.pack(side="left", fill="both")


# Left Frame
LeftFrame = Frame(root, relief = "solid", bd = 1)

ChooseSrc = Button(LeftFrame, text = "Select Image A", font = (u_font, 10), anchor = "center", command = ChooseFileA)
ChooseDst = Button(LeftFrame, text = "Select Image/Video B", font = (u_font, 10), anchor = "center", command = ChooseFileB)
Convert = Button(LeftFrame, text = "Convert Now!", font = (u_font, 10), anchor = "center", command=FaceSwap)
ChooseSrc.pack(side="top", fill = "x", padx=5, pady=5)
ChooseDst.pack(side="top", fill = "x", padx=5, pady=5)
Convert.pack(side="bottom", fill = "x", padx=5, pady=5)

WarpArea = LabelFrame(LeftFrame, text="Warp", relief = "solid", bd = 1)
WarpChoice = [("2D Warp", 1), ("3D Warp", 2)]
v1 = IntVar()
ChooseWarp1 = Radiobutton(WarpArea, text="2D Warp", variable=v1, value=1, command=Set2DWarp)
ChooseWarp1.pack(anchor="w", padx=5, pady=5)
ChooseWarp2 = Radiobutton(WarpArea, text="3D Warp", variable=v1, value=0, command=Set3DWarp)
ChooseWarp2.pack(anchor="w", padx=5, pady=5)
WarpArea.pack(side="top", fill="both", padx=5, pady=5)

ColorArea = LabelFrame(LeftFrame, text="Color Correct", relief = "solid", bd = 1)
v2 = IntVar()

ChooseColor1 = Radiobutton(ColorArea, text="Yes", variable=v2, value=1, command=SetColorCorrect)
ChooseColor1.pack(anchor="w", padx=5, pady=5)
ChooseColor2 = Radiobutton(ColorArea, text="No", variable=v2, value=0, command=ResetColorCorrect)
ChooseColor2.pack(anchor="w", padx=5, pady=5)
ColorArea.pack(side="top", fill="both", padx=5, pady=5)

TextScrollbar = Scrollbar(LeftFrame)
Introduction = Text(LeftFrame, yscrollcommand = TextScrollbar.set, width = 30, font = (u_font, 10))
Introduction.insert("insert", Tutorial)
Introduction.config(state=DISABLED)
TextScrollbar.config(command=Introduction.yview)
TextScrollbar.pack(side="right", fill="y", padx=5, pady=5)
Introduction.pack(side="left", fill="y", padx=5, pady=5)

# Image Frame
ImageFrame = Frame(root, relief = "solid", bd = 1)

PhotoFrame1 = Frame(ImageFrame)
PhotoFrame2 = Frame(ImageFrame)
PhotoFrame3 = Frame(ImageFrame)

Photo1 = Label(PhotoFrame1, image = Img1, height = ImageSize, width = ImageSize, bg = "White", relief = "solid", bd = 1)
Photo2 = Label(PhotoFrame2, image = Img1, height = ImageSize, width = ImageSize, bg = "White", relief = "solid", bd = 1)
Photo3 = Label(PhotoFrame3, image = Img1, height = ImageSize, width = ImageSize, bg = "White", relief = "solid", bd = 1)

Photo1.pack(side="top", fill="both", padx=5, pady=5)
Photo2.pack(side="top", fill="both", padx=5, pady=5)
Photo3.pack(side="top", fill="both", padx=5, pady=5)

PhotoLabel1 = Button(PhotoFrame1, text = "  A  ", font = (u_font, 10), anchor = "center")
VideoButton2 = Button(PhotoFrame2, text="  B  ", font = (u_font, 10), anchor = "center")
VideoButton3 = Button(PhotoFrame3, text = "Result", font = (u_font, 10), anchor = "center")

PhotoLabel1.pack(side="top", fill="both", padx=5, pady=5)
VideoButton2.pack(side="top", fill="both", padx=5, pady=5)
VideoButton3.pack(side="top", fill="both", padx=5, pady=5)


PhotoFrame1.pack(side="left", fill="y")
PhotoFrame2.pack(side="left", fill="y")
PhotoFrame3.pack(side="left", fill="y")

# Terminal Frame
TerminalFrame = Frame(root, relief = "solid", bd = 1, bg = "White")

CodeScrollbar = Scrollbar(TerminalFrame)
Terminal = Text(TerminalFrame, yscrollcommand = CodeScrollbar.set, font = (u_font, 10))
Terminal.insert("insert","-Terminal-\n")
CodeScrollbar.config(command=Terminal.yview)
CodeScrollbar.pack(side="right", fill="y", padx=5, pady=5)
Terminal.pack(side="bottom", fill="both", padx=5, pady=5)
Terminal.see(END)

HeadFrame.pack(side="top", fill="x", padx=5, pady=5)
LeftFrame.pack(side="left", fill="y", padx=5, pady=5)
ImageFrame.pack(side="top", fill="both", padx=5, pady=5)
TerminalFrame.pack(side="bottom", fill="x", padx=5, pady=5)

