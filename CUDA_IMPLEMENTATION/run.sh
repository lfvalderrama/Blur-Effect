nvcc `pkg-config --cflags opencv` -arch compute_20 blur_cuda.cu -lpthread `pkg-config --libs opencv` -o blur_cuda.out
TIMEFORMAT=%R

tam_kernel=1    #Tamaño del kernel para el efecto blur
num_threads=192   #Numero de hilos a usar
num_blocks=1      #Numero de bloques de hilos a usar
image=../test_images/1080p.jpg #Ruta de la imagen

echo "Comenzando proceso en POSIX con tamaño de kernel " $tam_kernel " y " $num_threads " hilos"
./blur_cuda.out $image $tam_kernel $num_threads $num_blocks
echo "Proceso terminado, la imagen modificada ha sido creada"
