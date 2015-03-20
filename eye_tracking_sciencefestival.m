
try
clear all
% system( 'start "mtlblink" "E:\Dropbox\Documents\University\Matlab Code\File Exchange Files\EyeTribe-Toolbox-for-Matlab\EyeTribe_for_Matlab\EyeTribe_Matlab_server.exe"' );
system( 'start "mtlblink" "D:\Dropbox\Documents\University\Matlab Code\File Exchange Files\EyeTribe-Toolbox-for-Matlab\EyeTribe_for_Matlab\EyeTribe_Matlab_server.exe"' );
Screen('Preference', 'SkipSyncTests', 1);
WaitSecs(2);

[success, connection] = eyetribe_init('test');
if ~success
    error('Couldn''t initialize');
end
% PsychDebugWindowConfiguration();
scr = Screen('OpenWindow', 0, 180);
screenSize = Screen('Rect', scr);
Screen('BlendFunction', scr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
xcen = screenSize(3)/2;
ycen = screenSize(4)/2;
ifi = 1/Screen('FrameRate', scr);
HideCursor;
KbName('UnifyKeyNames');
DrawFormattedText(scr, 'Welcome to the eye-tracking experiment. First, we need to calibrate the screen.\n\nSimply follow the red dot that will move across the screen with your eyes.\n\nPress enter to start!', 'center', 'center', 0);
Screen('Flip', scr);
WaitSecs(1);
KbStrokeWait;

success = eyetribe_calibrate_scifest(connection, scr);

WaitSecs(1);

%% Check if working!
kDown = 0;
success = eyetribe_start_recording(connection);
while ~kDown
    [kDown, ~, keyCode] = KbCheck;
    [~, x, y] = eyetribe_sample(connection);
    DrawFormattedText(scr, 'The computer should now be tracking your eyes. If it''s working, press enter!', 'center', 'center', 0);
    Screen('FillOval', scr, [125 255 125], [x-10 y-10 x+10 y+10]);
    Screen('Flip', scr);
end
success = eyetribe_stop_recording(connection);
if keyCode(KbName('Escape'));
    error('Calibration did not work');
end

%% Picture of Children
DrawFormattedText(scr, 'Great! Now look at the following picture.', 'center', 'center', 0);
Screen('Flip', scr);
WaitSecs(3);

imarray = imread(fullfile(pwd, 'Pictures', '33.jpg'));
imarray = imresize(imarray, 1.5);
Screen('PutImage', scr, imarray);
Screen('Flip', scr);

% recording routine
success = eyetribe_start_recording(connection);
t0 = GetSecs; i = 0;
while GetSecs < t0 + 4
    i = i+1;
    WaitSecs(ifi);
    [succes, x(i), y(i)] = eyetribe_sample(connection);
end
success = eyetribe_stop_recording(connection);

DrawFormattedText(scr, 'Thanks :) Now, here is what you were looking at:', 'center', 'center', 0);
Screen('Flip', scr);
t0 = WaitSecs(3);
times = linspace(t0, t0+4, numel(x));
for i = 1:numel(x);
    Screen('PutImage', scr, imarray);
    Screen('FillOval', scr, [125 255 125], [x(i)-10 y(i)-10 x(i)+10 y(i)+10]);
    if i > 1
        last10 = i-1:-1:i-10;
        last10(last10<1)=[];
    for ii = last10
        alphaV = 255 - (i-ii)*0.1*255;
        Screen('FillOval', scr, [125 255 125 alphaV], [x(ii)-10 y(ii)-10 x(ii)+10 y(ii)+10]);
    end
    end
    Screen('Flip', scr, times(i));
end
WaitSecs(1);

DrawFormattedText(scr, 'Most people look at the eyes of a person in a picture like that.\n\nWas that true for you?\n\nPress enter to continue!', 'center', 'center', 0);
Screen('Flip', scr);

KbStrokeWait;

%% Two pictures, social v nonsocial
DrawFormattedText(scr, 'Now look at the following two pictures.', 'center', 'center', 0);
Screen('Flip', scr);
WaitSecs(3);

imarray1 = imread(fullfile(pwd, 'Pictures', '31.jpg'));
imrect1 = [xcen-2*size(imarray1, 1), ycen-size(imarray1, 2)/2, xcen, ycen+size(imarray1, 2)/2];
imarray2 = imread(fullfile(pwd, 'Pictures', '32.jpg'));
imrect2 = [xcen, ycen-size(imarray2, 2)/2, xcen+2*size(imarray2, 1), ycen+size(imarray2, 2)/2];
Screen('PutImage', scr, imarray1, imrect1);
Screen('PutImage', scr, imarray2, imrect2);
Screen('Flip', scr);


x = []; y = [];
success = eyetribe_start_recording(connection);
t0 = GetSecs; i = 0;
while GetSecs < t0 + 6
    i = i+1;
    WaitSecs(ifi);
    [succes, x(i), y(i)] = eyetribe_sample(connection);
end
success = eyetribe_stop_recording(connection);

DrawFormattedText(scr, 'Alright! Again, here is what you were looking at:', 'center', 'center', 0);
Screen('Flip', scr);
t0 = WaitSecs(3);
times = linspace(t0, t0+6, numel(x));
for i = 1:numel(x);
    Screen('PutImage', scr, imarray1, imrect1);
    Screen('PutImage', scr, imarray2, imrect2);
    Screen('FillOval', scr, [125 255 125], [x(i)-10 y(i)-10 x(i)+10 y(i)+10]);
    if i > 1
        last10 = i-1:-1:i-10;
        last10(last10<1)=[];
    for ii = last10
        alphaV = 255 - (i-ii)*0.1*255;
        Screen('FillOval', scr, [125 255 125 alphaV], [x(ii)-10 y(ii)-10 x(ii)+10 y(ii)+10]);
    end
    end
    Screen('Flip', scr, times(i));
end
WaitSecs(1);

babyTime = 100* sum(x < xcen) / numel(x);
pizzaTime = 100* sum(x > xcen)  / numel(x);

if babyTime > pizzaTime
    messg = sprintf(['Many people look at the picture of the baby more than that of the pizza.\n\n' ...
                    'For you, this was true: You looked at the baby %.0f %% of the time, and the pizza %.0f %% of the time!\n\n'... 
                    'Often, people who have many autistic traits are the ones who show less preference for the baby picture.\n\nHowever, people who prefer the pizza could just be hungry!\n\n'...
                    'Thanks for taking part - press any key to exit.'], babyTime, pizzaTime);
else
    messg = sprintf(['Many people look at the picture of the baby more than that of the pizza.\n\n' ...
                    'For you, this was not true: You looked at the baby %.0f %% of the time, and the pizza %.0f %% of the time!\n\n'... 
                    'Often, people who have many autistic traits are the ones who show less preference for the baby picture.\n\nHowever, people who prefer the pizza could just be hungry!\n\n'...
                    'Thanks for taking part - press any key to exit.'], babyTime, pizzaTime);
end

DrawFormattedText(scr, messg, 'center', 'center', 0);
Screen('Flip', scr);

KbStrokeWait;



%% Shutdown Routine
% stop recording
success = eyetribe_stop_recording(connection);
WaitSecs(0.1);

% close connection
success = eyetribe_close(connection);

% close window
sca;

catch err
%% Shutdown Routine
% stop recording
success = eyetribe_stop_recording(connection);

% close connection
success = eyetribe_close(connection);

% close window
sca;
rethrow(err);
end