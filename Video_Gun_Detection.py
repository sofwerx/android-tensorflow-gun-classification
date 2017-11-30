
# coding: utf-8

# In[2]:



# I used this code to perform testing with an airsoftgun ak47 with my computer. 
# I used this in a docker container that had access.
# If you have not used open cv2 before, this code may not work.
# if you would like to know how to make this work on your computer
# please feel free to comment



import os
import cv2
import timeit
import numpy as np
import tensorflow as tf
from IPython.display import clear_output


camera = cv2.VideoCapture(0)

# Loads label file, strips off carriage return
label_lines = [line.rstrip() for line
               in tf.gfile.GFile('/root/tf_files/retrained_labels.txt')]

def grabVideoFeed():
    grabbed, frame = camera.read()
    return frame if grabbed else None

def initialSetup():
    os.environ['TF_CPP_MIN_LOG_LEVEL'] = '2'
    start_time = timeit.default_timer()

    # This takes 2-5 seconds to run
    # Unpersists graph from file
    with tf.gfile.FastGFile('/root/tf_files/retrained_graph.pb', 'rb') as f:
        graph_def = tf.GraphDef()
        graph_def.ParseFromString(f.read())
        tf.import_graph_def(graph_def, name='')

    print 'Took {} seconds to unpersist the graph'.format(timeit.default_timer() - start_time)

initialSetup()

with tf.Session() as sess:
    start_time = timeit.default_timer()

    # Feed the image_data as input to the graph and get first prediction
    softmax_tensor = sess.graph.get_tensor_by_name('final_result:0')

    print 'Took {} seconds to feed data to graph'.format(timeit.default_timer() - start_time)

    while True:
        frame = grabVideoFeed()

        if frame is None:
            raise SystemError('Issue grabbing the frame')

        frame = cv2.resize(frame, (299, 299), interpolation=cv2.INTER_CUBIC)

        

        # adhere to TS graph input structure
        numpy_frame = np.asarray(frame)
        numpy_frame = cv2.normalize(numpy_frame.astype('float'), None, -0.5, .5, cv2.NORM_MINMAX)
        numpy_final = np.expand_dims(numpy_frame, axis=0)

        start_time = timeit.default_timer()

        # This takes 2-5 seconds as well
        predictions = sess.run(softmax_tensor, {'Mul:0': numpy_final})
        score = predictions.item(1)
        gunScore =str(score)
        #print(predictions.item(1))
        

        print 'Took {} seconds to perform prediction'.format(timeit.default_timer() - start_time)

        start_time = timeit.default_timer()

        # Sort to show labels of first prediction in order of confidence
        top_k = predictions[0].argsort()[-len(predictions[0]):][::-1]

        print 'Took {} seconds to sort the predictions'.format(timeit.default_timer() - start_time)

        for node_id in top_k:
            human_string = label_lines[node_id]
            score = predictions[0][node_id]
            print('%s (score = %.5f)' % (human_string, score))
            

        print '********* Session Ended *********'
        font = cv2.FONT_HERSHEY_SIMPLEX
        cv2.putText(frame, gunScore, (10,200), font, 0.8, (0, 255, 0), 2)
        cv2.imshow('Main', frame)

        clear_output()

        if cv2.waitKey(1) & 0xFF == ord('q'):
            sess.close()
            break

camera.release()
cv2.destroyAllWindows()


# In[ ]:





# In[ ]:




