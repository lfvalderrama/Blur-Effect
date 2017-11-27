g++ `pkg-config --cflags opencv` blur_posix.cpp `pkg-config --libs opencv` -lpthread -o blur_posix.out

tam_kernel=1    #Tamaño del kernel para el efecto blur
num_threads=1   #Numero de hilos a usar
image=1080p.jpg #Ruta de la imagen, debe estar en la misma carpeta de ejecucion

echo "Comenzando proceso en POSIX con tamaño de kernel " $tam_kernel " y " $num_threads " hilos"
./blur_posix.out $image $tam_kernel $num_threads
echo "Proceso terminado, la imagen modificada ha sido creada"
