#!/bin/sh

#Author Aziz Mousa
#Copyright (c) zezomousa101


COMPILER_DIR="compiler"
readonly COMPILER_DIR
EQUALIZER_DIR="equalizer"
readonly EQUALIZER_DIR
SERVER_DIR="Sketch_builder_server"
readonly SERVER_DIR
GENERATOR_DIR="SketchBuilderCodeGenerator"
readonly GENERATOR_DIR
UI_DIR="Sketch-Builder-UI"
readonly UI_DIR
CPP_PROJECT="cpp"
readonly CPP_PROJECT
JAVA_PROJECT="java"
readonly JAVA_PROJECT
CURRENT_PATH="$(pwd)"
readonly CURRENT_PATH
CONFIG_FILE_ID="1mGTFCG2KgpQlczzK4I9A8G0yjxkBMS4J"
readonly CONFIG_FILE_ID
CONFIG_FILE_NAME="config.tar.gz"
readonly CONFIG_FILE_NAME

echoSeparate(){
	echo "--------------------------------------------------------------------"
}

#isLastProcessSuccess is a function to check last process and take two args
#-1 success message
#2- faild message
isLastProcessSuccess(){
	if [ $? -eq 0 ]; then
	    echo "$1"
	else
	    echo "$2"
	    exit
	fi
}

#clone git repo function has two args
#1- the git link
#2- the dir name that will be exists.
cloneRepo(){

	#clone process:
	echo "*clone $2 part:"
	if [ ! -d $2 ]; then
	  git clone $1
	fi
	#check if compiler process done successful or not
	isLastProcessSuccess "clone success." "clone faild"
	echoSeparate
}

#start building the cloned projects
#compile function should take two args :
#1- the projcet dir
#2- the project type $JAVA_PROJECT or CPP_PROJECT
compileProject(){

	#compile generator Part process
	
	cd $1
	echo "compilling $1 Part: "

	if [ $2 = $CPP_PROJECT ]
	then
		
		mkdir build
		cd build

		#prepare to compile
		cmake ..

		#compile
		make

		#check if compiling done successful
		isLastProcessSuccess "$1 compile success." "$1 compile faild"
		
		cd ..
		cd ..
		echoSeparate
	elif [ $2 = $JAVA_PROJECT ]; then

		#compile
		./gradlew clean build

		#check if compiling done successful
		isLastProcessSuccess "$1 compile success." "$1 compile faild"

		cd ..
		echoSeparate
		
	fi
}

compileTheRunner(){
	cd "$CURRENT_PATH"
	echo "compilling the runner app."

	#create directory to clone project parts
	if [ ! -d "build" ]; then
	  mkdir build
	fi

	cd build
	cmake ..
	make
	#check if compiling done successful
	isLastProcessSuccess "runner compile success." "runner compile faild"
	cd ..
}

#fucntion to donwload files from google drive, take two args
#1- file id
#2- file name
getGDriveFile(){
	CONFIRM=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate "https://docs.google.com/uc?export=download&id=$1" -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')
  	wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$CONFIRM&id=$1" -O $2
  
	rm -rf /tmp/cookies.txt
}

#copy function take two args source and distination
copy(){
	echo "copy $1 binary"
	cp -TRf "$1" "$2"
	isLastProcessSuccess "copy done" "copy faild"
}

#create file and set binary paths to it
initBinaryConfig(){
	if [ ! -d "$CURRENT_PATH/bin/.config" ]; then
  		mkdir "$CURRENT_PATH/bin/.config" 
	fi
	{
		echo "bin/compiler"
		echo "bin/equalizer"
		echo "bin/generator.jar"
		echo "bin/ui.jar"
	} >$CURRENT_PATH/bin/.config/binary.config
}

#create directory to clone project parts
if [ ! -d "clone" ]; then
  mkdir clone
fi

cd clone


echo "start cloning process:"

#clone compiler part
cloneRepo https://github.com/zezomousa101/compiler.git $COMPILER_DIR

#clone equalizer part
cloneRepo https://github.com/zezomousa101/equalizer.git $EQUALIZER_DIR

#clone generator part
cloneRepo https://github.com/hatematef07/SketchBuilderCodeGenerator.git $GENERATOR_DIR

#clone UI part
cloneRepo https://github.com/Alaa-Yasser/Sketch-Builder-UI.git $UI_DIR

#clone server part
cloneRepo https://github.com/zezomousa101/Sketch_builder_server.git $SERVER_DIR

echo "cloning is done."
echo "start building process:"


#compile compiler
compileProject $COMPILER_DIR $CPP_PROJECT

#compile equalizer
compileProject $EQUALIZER_DIR $CPP_PROJECT

#compile server
compileProject $SERVER_DIR $CPP_PROJECT

#compile ui
compileProject $UI_DIR $JAVA_PROJECT

# #compile generator
compileProject $GENERATOR_DIR $JAVA_PROJECT

#compile runner
compileTheRunner

echo "compilation process are done successfully."
echoSeparate

echo "Preparation process Start:"

echo "copy UI dependencies:"
#copy ui help dir
copy "$CURRENT_PATH/clone/$UI_DIR/Help" "$CURRENT_PATH/bin/Help"
#copy ui icons dir
copy "$CURRENT_PATH/clone/$UI_DIR/icons" "$CURRENT_PATH/bin/icons"

#copy generator icons
copy "$CURRENT_PATH/clone/$GENERATOR_DIR/icons" "$CURRENT_PATH/bin/icons"

#download config files
if [ ! -f "$CONFIG_FILE_NAME" ]; then
	echo "download compiler dependencies:"
  	getGDriveFile "$CONFIG_FILE_ID" "$CONFIG_FILE_NAME"
  	isLastProcessSuccess "download Success" "download faild"
fi


#extract config files
echo "extract config file:"
tar -xvf "$CURRENT_PATH/$CONFIG_FILE_NAME" -C "$CURRENT_PATH/bin"
isLastProcessSuccess "extraction done" "extraction faild"

#copy binaries to bin dir

if [ ! -d "$CURRENT_PATH/bin/bin" ]; then
  mkdir "$CURRENT_PATH/bin/bin" 
fi

#copy compiler binary
copy "$CURRENT_PATH/clone/$COMPILER_DIR/bin/compiler" "$CURRENT_PATH/bin/bin/compiler"

#copy equalizer binary
copy "$CURRENT_PATH/clone/$EQUALIZER_DIR/bin/equalizer" "$CURRENT_PATH/bin/bin/equalizer"

#copy server binary
copy "$CURRENT_PATH/clone/$SERVER_DIR/bin/server" "$CURRENT_PATH/bin/bin/server"

#copy UI binary
copy "$CURRENT_PATH/clone/$UI_DIR/build/libs/ui.jar" "$CURRENT_PATH/bin/bin/ui.jar"

#copy generator binary
copy "$CURRENT_PATH/clone/$GENERATOR_DIR/build/libs/generator.jar" "$CURRENT_PATH/bin/bin/generator.jar"

initBinaryConfig
isLastProcessSuccess "installation done successfully." "installation faild."