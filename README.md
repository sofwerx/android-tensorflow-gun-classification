# Android Tensorflow Gun Detection

### Description
Identify an AK47 using tensorflow software in an android device. This readme is  instructions to train and deploy tensorflow software to detect an AK47. The name of the folders within the image folder will be the name of the classifcation. This implentation is a proof of concept. Please feel free contribute to the code.

This code can be used to train your own models. All you would need to do is to create new folders in the tf_files/images directory and put the images in the folder. Please label the folder the object name since that is what you will see when the app tries to identify the object. 

### Images
I used the Fatkun google chrome addin to batched download images [addin to download images for training](https://www.pcsteps.com/5170-mass-download-images-chrome/). I google searched Ak47, People, Farm Tools, and Metal and Wood. I created a folder for each object and put the downloaded images to that folder location. I had the model classify the other classes so the model would not be confused when the phone camera was pointed to people, wood, metal, and farm tool objects. 

### Model
I chose to use the inception model for easy integration into the android app. This model also allows for real-time classification on newer android device. If you are installing this app on an old phone or tablet, it is going to be really slow. The model will predict  a gun, people with farm tools, and metal/wood objects. I added these classifications to the model so the gun model would not be confused when pionted at these objects.

### Android Device
I used the Galaxy S8 and Galaxy Tab for testing. The Tab was very very slow for object recognition. I also installed adb and verified that adb can detect the phone. I followed this link for adb installation [What is adb](https://developer.android.com/studio/command-line/adb.html#move). There are also many articles and youtube videos on how to install adb and detect the device.



### Assumptions
* docker installed
* docker-compose installed
* adb installed
* ubuntu 16.04 lts installed
* git installed
* have android phone


## Train and Deploy Ak47 TF Classify App
### Installation

Download git repository

```
git clone https://github.com/sofwerx/android_tensorflow_gun_detection.git $HOME/android_tensorflow_gun_detection
cd $HOME/android-tensorflow_gun_detection

```

Use `docker-compose up` to build and run:

```
docker-compose up
```

Alternatively, if you prefer the `docker` commands instead of `docker-compose`, you can use:

```
    docker build -t android_tensorflow_gun_detection .
    docker run --rm -v $PWD/outputs/:/outputs/ android_tensorflow_gun_detection
```

The `outputs/` folder should now have the APK available for you to install on your phone.

```
adb install outputs/*debug*.pk
```

## Additional Resource Information

* [Creating an image classifier on Android using TensorFlow (part 3)](https://medium.com/@daj/creating-an-image-classifier-on-android-using-tensorflow-part-3-215d61cb5fcd)
* [What is adb](https://developer.android.com/studio/command-line/adb.html#move)
* [Addin to download images for training](https://www.pcsteps.com/5170-mass-download-images-chrome/)

