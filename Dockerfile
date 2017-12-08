FROM gcr.io/tensorflow/tensorflow:1.4.0-devel
MAINTAINER Sofwerx Devops <devops@sofwerx.org>

#WORKDIR /root
#EXPOSE 8888/tcp
#EXPOSE 6006/tcp
#
#RUN /bin/sh -c tensorflow/tools/ci_build/builds/configured CPU
#RUN bazel build -c opt --cxxopt="-D_GLIBCXX_USE_CXX11_ABI=0" tensorflow/tools/pip_package:build_pip_package && \
#    bazel-bin/tensorflow/tools/pip_package/build_pip_package /tmp/pip && \
#    pip --no-cache-dir install --upgrade /tmp/pip/tensorflow-*.whl && \
#    rm -rf /tmp/pip && \
#    rm -rf /root/.cache
#
#ENV CI_BUILD_PYTHON=python
#
#WORKDIR /tensorflow
#
#WORKDIR /bazel
#ENV BAZEL_VERSION=0.5.0
#RUN curl -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/57.0.2987.133 Safari/537.36" \
#         -fSsL -O https://github.com/bazelbuild/bazel/releases/download/${BAZEL_VERSION}/bazel-${BAZEL_VERSION}-installer-linux-x86_64.sh && \
#    curl -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/57.0.2987.133 Safari/537.36" \
#         -fSsL -o /bazel/LICENSE.txt https://raw.githubusercontent.com/bazelbuild/bazel/master/LICENSE && \
#    chmod +x bazel-*.sh && \
#    ./bazel-${BAZEL_VERSION}-installer-linux-x86_64.sh && \
#    cd / && \
#    rm -f /bazel/bazel-${BAZEL_VERSION}-installer-linux-x86_64.sh
#RUN echo "build --spawn_strategy=standalone --genrule_strategy=standalone"     >>/etc/bazel.bazelrc
#RUN echo "startup --batch" >>/etc/bazel.bazelrc
#
# /
# /root/.jupyter
#
#RUN pip --no-cache-dir install ipykernel jupyter matplotlib numpy scipy sklearn pandas && python -m ipykernel.kernelspec
#RUN curl -fSsL -O https://bootstrap.pypa.io/get-pip.py && \
#    python get-pip.py && \
#    rm get-pip.py
#
#RUN apt-get update && \
#    apt-get install -y --no-install-recommends build-essential curl git libcurl3-dev libfreetype6-dev libpng12-dev libzmq3-dev pkg-config python-dev rsync software-properties-common unzip zip zlib1g-dev openjdk-8-jdk openjdk-8-jre-headless && \
#    apt-get clean && \
#    rm -rf /var/lib/apt/lists/*
#
#RUN mkdir -p /run/systemd && \
#    echo 'docker' > /run/systemd/container
#
#RUN sed -i 's/^#\s*\(deb.*universe\)$/\1/g' /etc/apt/sources.list
#
#RUN echo '#!/bin/sh' > /usr/sbin/policy-rc.d && \
#    echo 'exit 101' >> /usr/sbin/policy-rc.d && \
#    chmod +x /usr/sbin/policy-rc.d && \
#    dpkg-divert --local --rename --add /sbin/initctl && \
#    cp -a /usr/sbin/policy-rc.d /sbin/initctl && \
#    sed -i 's/^exit.*/exit 0/' /sbin/initctl && \
#    echo 'force-unsafe-io' > /etc/dpkg/dpkg.cfg.d/docker-apt-speedup && \
#    echo 'DPkg::Post-Invoke { "rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true"; };' > /etc/apt/apt.conf.d/docker-clean  && \
#    echo 'APT::Update::Post-Invoke { "rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true"; };' >> /etc/apt/apt.conf.d/docker-clean && \
#    echo 'Dir::Cache::pkgcache ""; Dir::Cache::srcpkgcache "";' >> /etc/apt/apt.conf.d/docker-clean && \
#    echo 'Acquire::Languages "none";' > /etc/apt/apt.conf.d/docker-no-languages && \
#    echo 'Acquire::GzipIndexes "true"; Acquire::CompressionTypes::Order:: "gz";' > /etc/apt/apt.conf.d/docker-gzip-indexes && \
#    echo 'Apt::AutoRemove::SuggestsImportant "false";' > /etc/apt/apt.conf.d/docker-autoremove-suggests

# /

#FROM danjarvis/tensorflow-android:1.0.0

##
## Below are the actual tensorflow-lite model training steps and android application build
##

WORKDIR /tensorflow

# Add the training files to the build
ADD tf_files/ /tf_files/

# Train inception model for tensorflow tf classifier app
RUN python tensorflow/examples/image_retraining/retrain.py \
    --bottleneck_dir=/tf_files/bottlenecks \
    --how_many_training_steps 500 \
    --model_dir=/tf_files/inception \
    --output_graph=/tf_files/retrained_graph.pb \
    --output_labels=/tf_files/retrained_labels.txt \
    --image_dir /tf_files/images

# Make sure that the docker container does not run out of memory
RUN bazel build --local_resources 4096,4.0,1.0 -j 1 tensorflow/python/tools:strip_unused

# Prepare trained model for android classifer app
RUN bazel-bin/tensorflow/python/tools/strip_unused \
    --input_graph=/tf_files/retrained_graph.pb \
    --output_graph=/tf_files/stripped_retrained_graph.pb \
    --input_node_names="Mul" \
    --output_node_names="final_result" \
    --input_binary=true

# Build app for some reason. This step might be skipped
RUN bazel build -c opt --local_resources 4096,4.0,1.0 -j 1 //tensorflow/examples/android:tensorflow_demo

# Move labels file, model file, and update parameters in classifier java code
RUN cp /tf_files/retrained_labels.txt /tensorflow/tensorflow/examples/android/assets/retrained_labels.txt
RUN cp /tf_files/stripped_retrained_graph.pb /tensorflow/tensorflow/examples/android/assets/stripped_retrained_graph.pb
RUN cp /tf_files/ClassifierActivityUpdated.java /tensorflow/tensorflow/examples/android/src/org/tensorflow/demo/ClassifierActivity.java

# Build new apk with new trained model
RUN bazel build -c opt --local_resources 4096,4.0,1.0 -j 1 //tensorflow/examples/android:tensorflow_demo

VOLUME /outputs

CMD cp /tensorflow/bazel-bin/tensorflow/examples/android/tensorflow_demo.apk /outputs
