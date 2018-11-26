
FROM ubuntu:xenial

# TODO: remove aptitude

RUN apt-get clean && \
  apt-get update && \
  apt-get install -y   \
    binutils                    \
    build-essential             \
    bzip2                       \
    ca-certificates             \
    coreutils                   \
    curl                        \
    findutils                   \
    gawk                        \
    git                         \
    less                        \
    libbz2-dev                  \
    libcairo2-dev               \
    libgmp-dev                  \
    libgtk-3-dev                \
    libncurses5-dev             \
    libncursesw5-dev            \
    libpango1.0-dev             \
    libreadline6-dev            \
    libreadline-dev             \
    libwebkitgtk-3.0-dev        \
    libyaml-dev                 \
    locales                     \
    netbase                     \
    net-tools                   \
    nodejs-legacy               \
    pkg-config                  \
    screen                      \
    tar                         \
    zlib1g-dev && \
  rm -rf /var/lib/apt/lists/* 


# Set the locale - was (and may still be ) necessary for ghcjs-boot to work
# Got this originally here: # http://askubuntu.com/questions/581458/how-to-configure-locales-to-unicode-in-a-docker-ubuntu-14-04-container
#
# 2015-10-25 It seems like ghcjs-boot works without this now but when I 
# removed it, vim starting emitting error messages when using plugins 
# pathogen and vim2hs together.  
#
RUN locale-gen en_US.UTF-8  

ENV LANG=en_US.UTF-8                  \
    LANGUAGE=en_US:en                 \
    LC_ALL=en_US.UTF-8                \
    PATH="/root/.local/bin:${PATH}"   \
    CARNAP_HM=/opt/carnap             \
    TAR_OPTIONS=--no-same-owner


RUN \ 
  mkdir -p ~/.local/bin && \
  curl --insecure -L https://www.stackage.org/stack/linux-x86_64 | tar xz --wildcards --strip-components=1 -C ~/.local/bin '*/stack' && \
  stack --resolver=lts-6.30 setup

RUN \
  stack --resolver=lts-6.30 install cabal-install alex happy 

RUN \
  stack --resolver=lts-8 install cabal-install hsc2hs-0.68.3

#  stack --resolver=lts-6.30 install cabal-install alex happy hscolour hsc2hs

ENV GHCJS_YAML=stack-ghcjs.yaml

COPY ${GHCJS_YAML} /tmp

RUN \
  mkdir /opt/ghcjs && \
  cd /opt/ghcjs && \
  cp /tmp/${GHCJS_YAML} . && \
  stack --stack-yaml=${GHCJS_YAML} --allow-different-user setup

RUN : "Carnap clone" && \
  mkdir -p ${CARNAP_HM} && \
  cd ${CARNAP_HM} && \
  git clone https://github.com/phlummox/Carnap.git .

WORKDIR ${CARNAP_HM}

RUN \
   stack build Carnap 
 
RUN set -x; \
   stack build --stack-yaml=${GHCJS_YAML} Carnap && \
   stack build --stack-yaml=${GHCJS_YAML} Carnap-Client && \
   stack build --stack-yaml=${GHCJS_YAML} Carnap-GHCJS 

RUN \
  stack install yesod-bin-1.5.1

COPY no-postgres-cabal.patch ./

RUN \
  git apply no-postgres-cabal.patch

RUN \
  stack build --dependencies-only Carnap-Server

COPY no-postgres-code.patch ./

RUN \
  git apply no-postgres-code.patch

RUN \
  stack build Carnap-Server

RUN \
  ln -s Carnap-Book book && \
  mkdir Carnap-Book/cache

COPY entry.sh .

CMD ["./entry.sh"]


