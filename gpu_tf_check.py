# Python
import tensorflow as tf
config = tf.ConfigProto()
config.gpu_options.allow_growth = True
hello = tf.constant('Hello, TensorFlow!')
sess = tf.Session(config=config)
print(sess.run(hello))
