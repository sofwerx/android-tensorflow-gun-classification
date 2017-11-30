# Android Tensorflow Gun Detection

### Description
Identify an AK47 using tensorflow software in an android device. This readme is  instructions to train and deploy tensorflow software to detect an AK47. The name of the folders within the image folder will be the name of the classifcation. This implentation is a proof of concept. Please feel free contribute to the code.

This code can be used to train your own models. All you would need to do is to create new folders in the tf_files/images directory and put the images in the folder. Please label the folder the object name since that is what you will see when the app tries to identify the object. 

### Images
I used the Fatkun google chrome addin to batched download images [addin to download images for training](https://www.pcsteps.com/5170-mass-download-images-chrome/). I google searched Ak47, People, Farm Tools, and Metal and Wood. I created a folder for each object and put the downloaded images to that folder location. I had the model classify the other classes so the model would not be confused when the phone camera was pointed to people, wood, metal, and farm tool objects. 

### Model
I chose to use the inception model for easy integration into the android app. This model also allows for real-time classification on newer android device. If you are installing this app on an old phone or tablet, it is going to be really slow.

### Android Device
I used the Galaxy S8 and Galaxy Tab for testing. The Tab was very very slow for object recognition. I also installed adb and verified that adb can detect the phone. I followed this link for adb installation [What is adb](https://developer.android.com/studio/command-line/adb.html#move). There are also many articles and youtube videos on how to install adb and detect the device.



### Assumptions
* docker installed
* adb installed
* ubuntu 16.04 lts installed
* git installed
* have android phone


## Train and Deploy Ak47 TF Classify App
### Installation

Download git repository
```
git clone git@github.com:sofwerx/android_tensorflow_gun_detection.git
```

Create a folder to mount to docker container. This is where docker will find the files for object recognition.

```
mkdir $HOME/tf_files
```

Run docker container to train model and build android apk. Note: Need to install Docker [install docker on 16.04 lts](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-16-04)
```
docker run -it -v $HOME/tf_files:/tf_files danjarvis/tensorflow-android:1.0.0
```
Train inception model for tensorflow tf classifier app
```
cd /tensorflow

python tensorflow/examples/image_retraining/retrain.py \
--bottleneck_dir=/tf_files/bottlenecks \
--how_many_training_steps 500 \
--model_dir=/tf_files/inception \
--output_graph=/tf_files/retrained_graph.pb \
--output_labels=/tf_files/retrained_labels.txt \
--image_dir /tf_files/images
```

Make sure that the docker container does not run out of memory

```
cd /tensorflow

bazel build --local_resources 4096,4.0,1.0 -j 1 tensorflow/python/tools:strip_unused
```
Prepare trained model for android classifer app

```
bazel-bin/tensorflow/python/tools/strip_unused \
--input_graph=/tf_files/retrained_graph.pb \
--output_graph=/tf_files/stripped_retrained_graph.pb \
--input_node_names="Mul" \
--output_node_names="final_result" \
--input_binary=true
```
Build app for some reason. This step might be skipped
```
cd /tensorflow

bazel build -c opt --local_resources 4096,4.0,1.0 -j 1 //tensorflow/examples/android:tensorflow_demo
```
Move labels file, model file, and update parameters in classifier java code
```
cp /tf_files/retrained_labels.txt /tensorflow/tensorflow/examples/android/assets/retrained_labels.txt

cp /tf_files/stripped_retrained_graph.pb /tensorflow/tensorflow/examples/android/assets/stripped_retrained_graph.pb

cp /tf_files/ClassifierActivityUpdated.java /tensorflow/tensorflow/examples/android/src/org/tensorflow/demo/ClassifierActivity.java
```
Build new apk with new trained model
```
cd /tensorflow

bazel build -c opt --local_resources 4096,4.0,1.0 -j 1 //tensorflow/examples/android:tensorflow_demo
```
Copy apk file from docker container to computer
```
cp /tensorflow/bazel-bin/tensorflow/examples/android/tensorflow_demo.apk /tf_files
```

install apk file to android device. This command will need to be run on outside of the docker container terminal Note: need to install adb
```
adb install -r $HOME/tf_files/tensorflow_demo.apk
```



## Additional Resource Information

* [Creating an image classifier on Android using TensorFlow (part 3)](https://medium.com/@daj/creating-an-image-classifier-on-android-using-tensorflow-part-3-215d61cb5fcd)
* [What is adb](https://developer.android.com/studio/command-line/adb.html#move)
* [Addin to download images for training](https://www.pcsteps.com/5170-mass-download-images-chrome/)

