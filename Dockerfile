FROM ubuntu as builder

RUN apt-get update > /dev/null && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends build-essential libreadline-dev libffi-dev git pkg-config libsdl2-2.0-0 libsdl2-dev python3 parallel ca-certificates > /dev/null && \
    rm -rf /var/lib/apt/lists/*

COPY ./.git /src/.git
COPY ./lib /src/lib
COPY ./mpy-cross /src/mpy-cross
COPY ./ports/unix /src/ports/unix
COPY ./py /src/py
COPY ./extmod /src/extmod
COPY ./shared /src/shared
COPY ./drivers /src/drivers
COPY ./tools /src/tools
COPY ./docs /src/docs

WORKDIR /src

RUN git submodule update --init --recursive lib/lv_bindings

RUN make -C mpy-cross && \
    make -C ports/unix submodules VARIANT=dev && \
    make -C ports/unix VARIANT=dev

FROM ubuntu

COPY --from=builder /src/ports/unix/micropython-dev /usr/local/bin

RUN apt-get update > /dev/null && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends libsdl2-2.0-0 > /dev/null && \
    rm -rf /var/lib/apt/lists/*
