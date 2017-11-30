
# Android Tensorflow Gun Detection

## Description
Identify AK47 using Tensorflow app in an Android device. This readme is short instructions to train and deploy Tensorflow Classifier App to detect an AK47. 

Assumptions
* docker installed
* adb installed
* ubuntu 16.04 lts installed
* have android phone




## Train and Deploy Ak47 TF Classify App

Create a folder named tf_files in home directory. Please copy tf_files folder contents to the tf_files folder created in home directory
```python
mkdir $HOME/tf_files
```

Run docker container to train model and build android apk. Note: Need to install Dokcer 
```
docker run -it -v $HOME/tf_files:/tf_files danjarvis/tensorflow-android:1.0.0
```
Train inception model for tensorflow classifier app
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

install apk file to android device. Note needt o install adb
```
adb install -r $HOME/tf_files/tensorflow_demo.apk
```



## additional resource information

* [Creating an image classifier on Android using TensorFlow (part 3)](https://medium.com/@daj/creating-an-image-classifier-on-android-using-tensorflow-part-3-215d61cb5fcd)
* [What is adb](https://developer.android.com/studio/command-line/adb.html#move)
* [Addin to download images for training](https://www.pcsteps.com/5170-mass-download-images-chrome/)

