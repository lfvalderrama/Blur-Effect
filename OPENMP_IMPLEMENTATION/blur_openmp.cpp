#include "opencv2/highgui/highgui.hpp"
#include <omp.h>
#include <iostream>

using namespace cv;
using namespace std;

Mat img;
Mat new_img;
int radio, NUM_THREADS;
//Funcion main
int main( int argc, char** argv )
{
  NUM_THREADS = atoi(argv[3]);
  int i, j;

  //Abrir las imagenes y guardarlas en memoria
  img = imread(argv[1], CV_LOAD_IMAGE_UNCHANGED);
  new_img = imread(argv[1], CV_LOAD_IMAGE_UNCHANGED);

  if (img.empty()){
      cout << "Error : Image cannot be loaded..!!" << endl;
      return -1;
  }

  radio=atoi(argv[2]);
  int width=img.cols;
  int height=img.rows;

  #pragma omp parallel for num_threads(NUM_THREADS) shared (new_img,img) collapse(2)
  for (i=0; i<height; i++){
   for (j=0; j<width; j++){
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
  string name = "MPmodificada_";
  name.append("kernel_");
  name.append(argv[2]);
  name.append(argv[1]);
  //Guardar la imagen
  imwrite(name, new_img);
  return 0;
}
