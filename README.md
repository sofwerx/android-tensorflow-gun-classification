# Android Tensorflow Gun Detection

### Description
Identify an AK47 utilizing TensorFlow software in an Android device. This readme contains instructions to train and deploy TensorFlow software to detect an AK47. The images (tf_files>images) are titled by classification. This implementation is a proof of concept. Please feel free to contribute to the code. 

This code can be utilized to train your own models. To do so, create new folders in the tf_files/images directory, title each with the respective object names and place the images in the folders. Please ensure to label the folder with the object name, since this title will correspond with the classification the app will present when attempting to identify an object.  

### Images
The Fatkun Batch Download Image (Google Chrome extension) was utilized to simultaneously download a bulk of images: [Addin to download images for training](https://www.pcsteps.com/5170-mass-download-images-chrome/). Google searches were completed for ‘AK47’, ‘people’, ‘farm tools’ and ‘metal and wood’. A folder was created for each search category and the downloaded images were placed in the corresponding folder. The model was tasked with classifying the other classes to avoid error and confusion within the model when the phone camera was oriented towards people, wood, metal and farm tool objects. 

### Model
The TensorFlow Inception Model was selected due to its ease of integration into the Android app. The model also enables real-time classification on newer Android devices. If this app is implemented on an older phone or tablet, its operation will be slow. The model will identify a gun, people with farm tools and metal/wood objects. The additional classifications were added to the gun model to eliminate error and confusion when the device camera is oriented towards these objects. 

### Android Device
The model was tested on the Galaxy S8 and Galaxy Tab. Object recognition was incredibly slow on the Galaxy Tab. Android Debug Bridge (adb) was installed and verified for detecting the phone. Installation for adb was completed through the following source instruction:  [What is adb](https://developer.android.com/studio/command-line/adb.html#move). Additionally, there are numerous articles and YouTube tutorials available on installing adb and detecting the device. 



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
git clone git@github.com:sofwerx/android_tensorflow_gun_detection.git $HOME/android_tensorflow_gun_detection

```

Run docker container to train model and build android apk. Note: Need to install Docker install docker on 16.04 lts

```
docker run -it -v $HOME/android_tensorflow_gun_detection/tf_files:/tf_files danjarvis/tensorflow-android:1.0.0
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
Install apk file to android device. This command will need to be run outside of the docker container terminal Note: need to install adb

```
adb install -r $HOME/android_tensorflow_gun_detection/tf_files/tensorflow_demo.apk

```

## Additional Resource Information

* [Creating an image classifier on Android using TensorFlow (part 3)](https://medium.com/@daj/creating-an-image-classifier-on-android-using-tensorflow-part-3-215d61cb5fcd)
* [What is adb](https://developer.android.com/studio/command-line/adb.html#move)
* [Addin to download images for training](https://www.pcsteps.com/5170-mass-download-images-chrome/)

