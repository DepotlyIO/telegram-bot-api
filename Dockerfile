# syntax = dockerfile:1

FROM debian:12-slim as build

WORKDIR /telegram

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y make \
                                               git \
                                               zlib1g-dev \
                                               libssl-dev \
                                               gperf \
                                               cmake \
                                               clang \
                                               libc++-dev \
                                               libc++abi-dev \
                                               ca-certificates

RUN git clone --recursive https://github.com/tdlib/telegram-bot-api.git .

WORKDIR /telegram/build

ENV CXXFLAGS="-stdlib=libc++"
ENV CC=/usr/bin/clang
ENV CXX=/usr/bin/clang++

RUN cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX:PATH=/usr/local ..

RUN cmake --build . --parallel $(nproc) --target install

FROM debian:12-slim as production

RUN mkdir /data && \
    apt-get update -qq && \
    apt-get install --no-install-recommends -y libssl-dev \
                                               libc++-dev

COPY --from=build /usr/local/bin/telegram-bot-api /usr/local/bin/telegram-bot-api

CMD ["telegram-bot-api", "--local", "-d", "/data", "-t", "/tmp"]
