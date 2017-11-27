g++ -fopenmp `pkg-config --cflags opencv` blur_openmp.cpp `pkg-config --libs opencv` -o blur_openmp.out


tam_kernel=1    #Tamaño del kernel para el efecto blur
num_threads=1   #Numero de hilos a usar
image=1080p.jpg #Ruta de la imagen

echo "Comenzando proceso en OpenMP con tamaño de kernel " $tam_kernel " y " $num_threads " hilos"
./blur_openmp.out $image $tam_kernel $num_threads
echo "Proceso terminado, la imagen modificada ha sido creada"
