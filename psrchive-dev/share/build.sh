cd psrchive

./bootstrap

./configure --prefix=$PSRCHIVE/install --x-libraries=/usr/lib/x86_64-linux-gnu --enable-shared --enable-static F77=gfortran

make -j $(nproc)

make

make install

echo "Predictor::default = tempo2" >> .psrchive.cfg
echo "Predictor::policy = default" >> .psrchive.cfg
