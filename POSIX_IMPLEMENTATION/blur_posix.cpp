#include "opencv2/highgui/highgui.hpp"
#include <iostream>
#include <pthread.h>

using namespace cv;
using namespace std;


Mat img;
Mat new_img;
int radio, NUM_THREADS;

//Funcion que se realiza en loshilos para generar el efecto borroso
void *blur(void *threadid) {
   long id;
   id = (long)threadid;
 	 int width=img.cols;
   int height=img.rows;
   for (int i=(id*(height/NUM_THREADS)); i<(id+1)*(height/NUM_THREADS); i++){
 		for (int j=0; j<width; j++){
 			int aux_r=0;	//2
 			int aux_g=0;	//1
 			int aux_b=0;	//0
 			int aux_div=1;
 			for (int a=1; a<=radio; a++){
 				if(!(i-a<0)){
 					aux_r+= img.at<cv::Vec3b>(i-a,j)[2];
 					aux_g+= img.at<cv::Vec3b>(i-a,j)[1];
 					aux_b+= img.at<cv::Vec3b>(i-a,j)[0];
 					aux_div++;
 				}
 				if(i+a<height){
 					aux_r+= img.at<cv::Vec3b>(i+a,j)[2];
 					aux_g+= img.at<cv::Vec3b>(i+a,j)[1];
 					aux_b+= img.at<cv::Vec3b>(i+a,j)[0];
 					aux_div++;
 				}
 				if(!(j-a<0)){
 					aux_r+= img.at<cv::Vec3b>(i,j-a)[2];
 					aux_g+= img.at<cv::Vec3b>(i,j-a)[1];
 					aux_b+= img.at<cv::Vec3b>(i,j-a)[0];
 					aux_div++;
 				}
 				if(j+a<width){
 					aux_r+= img.at<cv::Vec3b>(i,j+a)[2];
 					aux_g+= img.at<cv::Vec3b>(i,j+a)[1];
 					aux_b+= img.at<cv::Vec3b>(i,j+a)[0];
 					aux_div++;
 				}
 			}
  	new_img.at<cv::Vec3b>(i,j)[2]=(img.at<cv::Vec3b>(i,j)[2]+aux_r)/(aux_div);
 		new_img.at<cv::Vec3b>(i,j)[1]=(img.at<cv::Vec3b>(i,j)[1]+aux_g)/(aux_div);
 		new_img.at<cv::Vec3b>(i,j)[0]=(img.at<cv::Vec3b>(i,j)[0]+aux_b)/(aux_div);
    }
  }
   pthread_exit(NULL);
}

//Funcion main
int main( int argc, char** argv )
{
  NUM_THREADS = atoi(argv[3]);
  pthread_t threads[NUM_THREADS];
  int i, rc;

  //Abrir las imagenes y guardarlas en memoria
  img = imread(argv[1], CV_LOAD_IMAGE_UNCHANGED);
  new_img = imread(argv[1], CV_LOAD_IMAGE_UNCHANGED);

  if (img.empty()){
      cout << "Error : Image cannot be loaded..!!" << endl;
      return -1;
  }

  radio=atoi(argv[2]);

  //Creacion de los hilos
  for( i = 0; i < NUM_THREADS; i++ ) {
     rc = pthread_create(&threads[i], NULL, blur, reinterpret_cast<void *>(i));

     if (rc) {
        cout << "Error:unable to create thread," << rc << endl;
        exit(-1);
     }
  }

//espera que todos los hilos terminen antes de continuar
  void *ret_join;
  for( i = 0; i < NUM_THREADS; i++ ) {
    rc = pthread_join(threads[i], &ret_join );
        if(rc != 0) {
                cout<<"pthread_join failed";
                exit(EXIT_FAILURE);
        }
  }
  string name = "modificada_";
  name.append("kernel_");
  name.append(argv[2]);
  name.append(argv[1]);
  //Guardar la imagen
  imwrite(name, new_img);
  return 0;
}
