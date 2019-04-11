close all

javaaddpath 'C:\Program Files\MATLAB\R2017b\java\jar\mij.jar'
javaaddpath 'C:\Program Files\MATLAB\R2017b\java\jar\ij.jar'
addpath('C:\Program Files\Fiji.app\scripts') 
Miji(false);                                                                        % starts FIJI without opening the window

path_folder=genpath(uigetdir);                                                      % saves path of the folder which contains the images
path_folder= path_folder(1:end-1);                                                  % deletes ';' and the end of the path
filelist = dir(fullfile(path_folder, '*.tif'));                                     % saves all tif images in one list

% writes position of '_' and '/' from parent directory in under0 and back0
back_count_path=strfind(path_folder,'\');     


%doubling of all '\' in the path
for n=1:length(back_count_path)
path_folder= strcat(path_folder(1:back_count_path(n)),'\',path_folder(back_count_path(n)+1:end));
back_count_path=back_count_path+1;
end

% starts an iteration for all images in the specified folder
for ii=1:length(filelist)
if ii==1                                                                            % the first time...
    MIJ.run('Open...', strcat('path=[',path_folder,'\\',filelist(ii).name,']'));    % loading the first image in FIJI 
    %MIJ.createImage(img)                                                           % if images are previously loaded into MATLAB
    MIJ.run('Trainable Weka Segmentation');                                         % runs the plugin for segmentation
    pause(1)                                                                        % waits until loading is finished
    trainableSegmentation.Weka_Segmentation.loadClassifier(strcat(path_folder,'\\classifier.model')); % loading the classifier by specifying its path
    %trainableSegmentation.Weka_Segmentation.loadClassifier('classifier.model');    % if the current folder is known, the name of the classifier model is sufficient 
    trainableSegmentation.Weka_Segmentation.getProbability;                         % gets the result of first image
else
    trainableSegmentation.Weka_Segmentation.applyClassifier(path_folder, filelist(ii).name,...        % applies classifier for the rest of the images
        'showResults=true', 'storeResults=false','probabilityMaps=true','');
    MIJ.run('Close',filelist(ii).name);                                             % closes the original image (otherwise the next iteration applyClassifier isn´t working)
end
I = MIJ.getCurrentImage;                                                            % loading the processed image to workspace                                                        
img(:,:,ii)=I(:,:,1);                                                               % saves only one of the two processed and in Fiji shown images to the new variable img (every iteration: img get a dimension higher)
figure, imshow(I(:,:,1))                                                            
MIJ.run('Close','Classification result')                                            % closes the processed image
end
MIJ.closeAllWindows                                                                 % closes the plugin for segmentation
MIJ.exit                                                                            % exits fiji