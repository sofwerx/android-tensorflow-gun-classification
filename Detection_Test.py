
# coding: utf-8

# In[2]:


# This code was used to test the ak47 object recognition on test images. I ran the code in jupyter notebook. 



# import packages
import tensorflow as tf, sys
import os, glob
from IPython.display import Image, display


# Get training labels
label_lines=[line.rstrip() for line in tf.gfile.GFile("/root/tf_files/retrained_labels.txt")]


# Import trained inception model
with tf.gfile.FastGFile("/root/tf_files/retrained_graph.pb", 'rb') as f:
    graph_def =  tf.GraphDef()
    graph_def.ParseFromString(f.read())
    _ = tf.import_graph_def(graph_def,name='')
    
    
    
    
 # Get images from directory and predict object uing trained model   
with tf.Session() as sess:
    
    os.chdir("/root/test_images")
    count1=1

    for file in glob.glob("*.jpg"):
    
        image_path = "/root/test_images" + '/' + file
        
        display(Image(filename=image_path))
        

        image_data=tf.gfile.FastGFile(image_path,'rb').read()

        softmax_tensor = sess.graph.get_tensor_by_name('final_result:0')

        predictions = sess.run(softmax_tensor, {'DecodeJpeg/contents:0': image_data})
    

        top_k = predictions[0].argsort()[-len(predictions[0]):][::-1]


        for node_id in top_k:
            human_string = label_lines[node_id]
            score = predictions[0][node_id]
            print('%s (score = %5f)' % (human_string,score))

        


# In[ ]:




