#!/bin/bash
####################################################################################################################
#####       Bash script that looks for T1-3D mri dicoms and converts to nii and mgz                            #####
####################################################################################################################
#
#recommendations: -this is set for folder_depth=3 from the starting folder, if you requre more (or less) add 
#                  (or remove) cycles over all directories
#                 
#Improvements:               
#              -generalizzare depth
#              -generealizzare la ricerca ad altri tag

mkdir MGZ_Folder
MGZ_PATH=$(pwd)

for i_dir in *                              #cycle over all directories (all subjects)
do
  if [ -d "$i_dir" ]
  then 
    cd "$i_dir"
#    echo "$i_dir"  
    for j_dir in *                          #cycle over all subdirectories        
    do
      if [ -d "$j_dir" ]
      then 
        cd "$j_dir" 
#        echo "$j_dir"
        for k_dir in *t1*                   #cycle over subsubdirectories containing t1
        do 
          if [ -d "$k_dir" ]
          then
            cd "$k_dir"                   
            for file in *                   #cycle for conversion DICOM->NIFTI->MGZ
            do
              if [[ $file == *.dcm ]]
              then                
                check3D=$(dicom_hdr $file | grep MR\ Acquisition\ Type\ //3D)
                lengthcheck=$(echo $check3D | awk '{print length}')
                if [ $lengthcheck != 0 ]
                then
                  Date_long=$(dicom_hdr $file | grep ID\ Image\ Date)
                  Date_medium=$(echo $Date_long | awk '{print $9}')
                  Date=${Date_medium:6}
                  ID_long=$(dicom_hdr $file | grep PAT\ Patient\ ID)
                  ID_medium=$(echo $ID_long | awk '{print $9}')
                  ID=${ID_medium:4}
                  filenome=$ID\_$Date\_$k_dir
                  echo $filenome                             
                  to3d -quit_on_err -prefix $filenome *.dcm
                  3dAFNItoNIFTI $filenome+orig -prefix *.nii
                  fslreorient2std $filenome.nii STD\_ORNT\_$filenome.nii
                  rm $filenome*
                  mri_convert STD\_ORNT\_$filenome.nii.gz $filenome.mgz
                  mv $filenome.mgz $MGZ_PATH/MGZ_Folder 
                  rm *.nii.gz
                  break
                fi
              fi
            done
            cd ..
          fi
        done

        for k_dir in *T1*                    #cycle over subsubdirectories containing T1
        do 
          if [ -d "$k_dir" ]
          then
            cd "$k_dir"
            for file in *                    #cycle for conversion DICOM->NIFTI->MGZ
            do
              if [[ $file == *.dcm ]]
              then               
                check3D=$(dicom_hdr $file | grep MR\ Acquisition\ Type\ //3D)
                lengthcheck=$(echo $check3D | awk '{print length}')
                if [ $lengthcheck != 0 ]
                then
                  Date_long=$(dicom_hdr $file | grep ID\ Image\ Date)
                  Date_medium=$(echo $Date_long | awk '{print $9}')
                  Date=${Date_medium:6}
                  ID_long=$(dicom_hdr $file | grep PAT\ Patient\ ID)
                  ID_medium=$(echo $ID_long | awk '{print $9}')
                  ID=${ID_medium:4}
                  filenome=$ID\_$Date\_$k_dir
                  echo $filenome                             
                  to3d -quit_on_err -prefix $filenome *.dcm
                  3dAFNItoNIFTI $filenome+orig -prefix *.nii
                  fslreorient2std $filenome.nii STD\_ORNT\_$filenome.nii
                  rm $filenome*
                  mri_convert STD\_ORNT\_$filenome.nii.gz $filenome.mgz
                  mv $filenome.mgz $MGZ_PATH/MGZ_Folder  
                  rm *.nii.gz                 
                  break
                fi
              fi
            done
            cd ..
          fi
        done
        cd .. 
      fi
    done
    cd ..
  fi   
done
   
