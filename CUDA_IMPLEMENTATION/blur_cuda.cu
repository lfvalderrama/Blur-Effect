#include "opencv2/highgui/highgui.hpp"
#include <iostream>
#include <stdio.h>

#include <cuda.h>

using namespace cv;
using namespace std;


Mat img;
Mat new_img;
int radio, NUM_THREADS;

// CUDA API error checking macro
static void handleError( cudaError_t err, const char *file,  int line ) {
    if (err != cudaSuccess) {
        printf( "%s in %s at line %d\n", cudaGetErrorString( err ),  file, line );
        exit( EXIT_FAILURE );
    }
}
#define cudaCheck( err ) (handleError( err, __FILE__, __LINE__ ))

//Funcion que se realiza en loshilos para generar el efecto borroso
__global__ void blur(int *r_in, int *r_out,int *g_in, int *g_out,int *b_in, int *b_out, int radio, int numthreads, int numblocks, int largo) {
   	int gindex = threadIdx.x + (blockIdx.x * blockDim.x);
		int aux = largo/(numthreads*numblocks)+1;
		for (int i=gindex*aux; i<(gindex+1)*(aux); i++){ 
		int aux_r = 0, aux_g = 0, aux_b = 0, count=0;

	 			for (int a=0; a<=radio; a++){
	 				if(!(i-a<0)){
	 					aux_r+= r_in[i-a];
	 					aux_g+= g_in[i-a];
	 					aux_b+= b_in[i-a];
						count++;
	 				}
	 				if(i+a<largo){
	 					aux_r+= r_in[i+a];
	 					aux_g+= g_in[i+a];
	 					aux_b+= b_in[i+a];
						count++;
	 				}
	 			}
				

			//promedio de pixeles sumados
			aux_r = int(aux_r/(count));
			aux_g = int(aux_g/(count));
			aux_b = int(aux_b/(count));

			//guardado del valor a enviar al host del nuevo valor del pixel

			r_out[i] = aux_r;
			g_out[i] = aux_g;
			b_out[i] = aux_b;
		}
}

//Funcion main
int main( int argc, char** argv )
{
  NUM_THREADS = atoi(argv[3]);
  int num_blocks = atoi(argv[4]);
  int  j, k;

  //Abrir las imagenes y guardarlas en memoria
  img = imread(argv[1], CV_LOAD_IMAGE_UNCHANGED);
  new_img = imread(argv[1], CV_LOAD_IMAGE_UNCHANGED);

  if (img.empty()){
      cout << "Error : Image cannot be loaded..!!" << endl;
      return -1;
  }

	int h_r_in[img.cols],h_r_out[img.cols],h_g_in[img.cols],h_g_out[img.cols],h_b_in[img.cols],h_b_out[img.cols];
 	//variables de device
  int *d_r_in, *d_r_out,*d_g_in, *d_g_out,*d_b_in, *d_b_out;
  radio=atoi(argv[2]);
	int largo=img.cols;
  //Reserva de recursos en device
  cudaMalloc( (void **) &d_r_in, img.cols * sizeof(int));
	cudaMalloc( (void **) &d_r_out, img.cols * sizeof(int));
	cudaMalloc( (void **) &d_g_in, img.cols * sizeof(int));
	cudaMalloc( (void **) &d_g_out, img.cols * sizeof(int));
	cudaMalloc( (void **) &d_b_in, img.cols * sizeof(int));
	cudaMalloc( (void **) &d_b_out, img.cols * sizeof(int));

  //k recorre fila por fila
  for(j=0;j<img.rows;j++){
      //asigna los valores de la fila actual en el host
      for(k=0;k<img.cols;k++){
        h_r_in[k] = int(img.at<Vec3b>(j,k)[0]);
				h_g_in[k] = int(img.at<Vec3b>(j,k)[1]);
				h_b_in[k] = int(img.at<Vec3b>(j,k)[2]);
			}

      //envia los valores de la fila actual del host al device
      cudaCheck( cudaMemcpy( d_r_in, h_r_in, img.cols * sizeof(int), cudaMemcpyHostToDevice));
			cudaCheck( cudaMemcpy( d_g_in, h_g_in, img.cols * sizeof(int), cudaMemcpyHostToDevice));
			cudaCheck( cudaMemcpy( d_b_in, h_b_in, img.cols * sizeof(int), cudaMemcpyHostToDevice));
      //ejecuta el stencil
      blur<<<num_blocks,NUM_THREADS>>> (d_r_in,d_r_out,d_g_in,d_g_out,d_b_in,d_b_out, radio, NUM_THREADS, num_blocks, largo);

      //guarda en el host los valores generados por el stencil
      cudaMemcpy( h_r_out, d_r_out, img.cols * sizeof(int), cudaMemcpyDeviceToHost);
      cudaMemcpy( h_g_out, d_g_out, img.cols * sizeof(int), cudaMemcpyDeviceToHost);
      cudaMemcpy( h_b_out, d_b_out, img.cols * sizeof(int), cudaMemcpyDeviceToHost);
      //recorre la fila actual y le asigna los nuevos valores rgb
      for(k=0;k<img.cols;k++){
        new_img.at<Vec3b>(j,k)[0] = h_r_out[k];
        new_img.at<Vec3b>(j,k)[1] = h_g_out[k];
        new_img.at<Vec3b>(j,k)[2] = h_b_out[k];
			}
  }
	

  string name = "modificada_";
  name.append("kernel_");
  name.append(argv[2]);
	name.append("_");
  name.append(argv[1]);
  //Guardar la imagen
  imwrite(name, new_img);
  return 0;
}


