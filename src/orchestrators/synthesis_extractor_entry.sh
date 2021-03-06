#!/bin/bash
  
    set -e 

    SCRIPT_PATH="../scripts"
    SI_PATHS="../SI"
    
    NAME_SPACE="soere"
    IP_HOST="localhost"    

    ################################################################
    # Arbo SI Configuration Ex
    ################################################################
    #
    #   + si_name
    #     - connection.txt
    #     + csv
    #       - semantic_si.csv
    #     + input
    #       + shared
    #         + Directory_01
    #           - mod.graphml
    #       + variables
    #         + variable_01
    #           - variable_01.graphml 
    #           - class.txt 
    #           - sparql.txt
    #         + variable_02
    #           - variable_02.graphml 
    #           - class.txt 
    #           - sparql.txt
    #
    ################################################################
    ################################################################
    
    
    ################################################################
    #
    ### CONFIGURATION ##############################################
    #
    ################################################################    

    # Port 
    RW="7777"
    RO="8888"
    # Database 
    DATA_BASE="postgresql" # Alternative : "mysql"
    # Extensions :
    EXT_OBDA="obda"
    EXT_GRAPH="graphml"
    # Class File ( Discriminators )
    CLASS_FILE_NAME="class.txt"
    SPARQL_FILE_NAME="sparql.txt"
    ## CSV Config
    CSV_SEP=";"
    INTRA_CSV_SEP=" -intra_sep , -intra_sep < -intra_sep > " 
    COLUMNSTO_VALIDATE=" -column 0 -column 1 -column 2 -column 4 -column 6 -column 7 -column 8 -column 10 "
    INPUT_CSV_FILE_NAME="semantic_si.csv"
    OUTPUT_VALIDE_CSV_FILE_NAME="pipeline_si.csv"
    # Connection
    CONNEC_FILE_NAME="connection.txt"
    
    # Ontop ARGS
    ONTOP_QUERY="SELECT ?S ?P ?O { ?S ?P ?O } "
    ONTOP_TTL_FORMAT="ttl"
    ONTOP_BATCH="batch" # disable : "" 
    #ONTOP_BATCH="" 
    ONTOP_PAGE_SIZE="200000"
    ONTOP_FLUSH_COUNT="500000"
    ONTOP_FRAGMENT="1000000"
    ONTOP_XMS="15g"
    ONTOP_XMX="15g"
    ONTOP_MERGE="" # For Merge : "merge" 
    ONTOP_LOG_LEVEL="ALL" # OFF , DEBUG , INFO , TRACE , WARN , ERROR  ; 
      
    CORESE_IGNORE_BREAK_LINE="corese_ignore_line_break" # Empty to disable     
    
    # Corese ARGS
    CORESE_QUERY=${CORESE_QUERY:-"SELECT ?S ?P ?O { ?S ?P ?O . filter( !isBlank(?S) ) . filter( !isBlank(?O) )  } "}
    CORESE_PEEK=${CORESE_PEEK:-"-peek 6 "}
    CORESE_FRAGMENT=${CORESE_FRAGMENT:-"-f 1000000 "}    
    CORESE_FORMAT=${CORESE_FORMAT:-"-F ttl "}
    CORESE_FLUSH_COUNT=${CORESE_FLUSH_COUNT:-"-flushCount 250000"}    
    CORESE_XMS=${CORESE_XMS:-"15g"}
    CORESE_XMX=${CORESE_XMX:-"15g"}
    
     
    ################################################
    ## DO NOT TOUCH ################################
    ################################################
    ################################################
    #
    # SCRIPT
    #
    ################################################    
    ################################################    
    
    echo 
    echo " 00 ============================ 00 "
    echo " ** ============================ ** "
    echo " ||   ____   ____  ___  _     __ || "
    echo " ||  / ___| / __ \|  _ \ \   / / || "
    echo " || | |    | |  | | |_) \ \_/ /  || "
    echo " || | |    | |  | |  _<  \   /   || "
    echo " || | |___ | |__| | |_) | | |    || "
    echo " ||  \____| \____/|____/  |_| v1 || "
    echo " || Portal                       || "
    echo " ** ============================ ** "
    echo " 00 ============================ 00 "   
   
    CURRENT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    cd $CURRENT_PATH
    ROOT_PATH="${CURRENT_PATH/}"
  
    EXIT() {
     if [ $PPID = 0 ] ; then exit ; fi
     parent_script=`ps -ocommand= -p $PPID | awk -F/ '{print $NF}' | awk '{print $1}'`
     if [ $parent_script = "bash" ] ; then
         echo; echo -e " \e[90m exited by : $0 \e[39m " ; echo
         exit 2
     else
         if [ $parent_script != "java" ] ; then 
            echo ; echo -e " \e[90m exited by : $0 \e[39m " ; echo
            kill -9 `ps --pid $$ -oppid=`;
            exit 2
         fi
         echo " Coby Exited "
         exit 2
     fi
    } 
        
    ##################################################
    ##  INSTALLATION  ################################
    ##################################################
    
    if [ "$#" -ne 2 -a "$1" == "-i" ] ; then 
         echo
         echo "  -> The arg [ -i ] is used only for installation. Cmd Ex : "$0" -i db=postgresql "
         EXIT
       
    elif [ "$#" -eq 2 -a "$1" == "-i" ] ; then 
    
        if [ "$2" != "db=postgresql" -a "$2" != "db=mysql" ] ;  then 
           echo
           echo "  -> Database must be : postgresql / mysql.  Cmd Ex : "$0" -i db=postgresql "
           EXIT
        fi
        
        s_db=$2
        db="${s_db/db=/''}"
        
        $SCRIPT_PATH/00_install_libs.sh db=$db
        
        EXIT 
    fi
   
    
    #####################################################
    #####################################################
    # COBY PIPELINE 
    #####################################################
    #####################################################
     
    if [ ! -d "$SI_PATHS" ]; then 
      echo  
      echo -e "\e[93m ERROR ### \e[32m "
      echo -e "\e[93m  =>> Missning Modelization. No [$SI_PATHS] Folder Provided ### \e[32m "
      EXIT
    fi
    
    SI=${1:-""}
   
    if [ -z "$SI" ] ; then
    
        for SI in `ls "$SI_PATHS" --ignore "ontology" --ignore "SI.txt" `;   do

         ./synthesis_extractor_process.sh ip=$IP_HOST                                       \
                                          namespace=$NAME_SPACE                             \
                                          ro=$RO                                            \
                                          rw=$RW                                            \
                                          si=$SI                                            \
                                          db=$DATA_BASE                                     \
                                          ext_obda=$EXT_OBDA                                \
                                          ext_graph=$EXT_GRAPH                              \
                                          class_file_name=$CLASS_FILE_NAME                  \
                                          sparql_file_name=$SPARQL_FILE_NAME                \
                                          csv_file_name=$INPUT_CSV_FILE_NAME                \
                                          valide_csv_file_name=$OUTPUT_VALIDE_CSV_FILE_NAME \
                                          csv_sep=$CSV_SEP                                  \
                                          intra_separators="$INTRA_CSV_SEP"                 \
                                          columns="$COLUMNSTO_VALIDATE"                     \
                                          connec_file_name=$CONNEC_FILE_NAME                \
                                                                                            \
                                          ontop_xms="$ONTOP_XMS"                            \
                                          ontop_xmx="$ONTOP_XMX"                            \
                                          ontop_ttl_format="$ONTOP_TTL_FORMAT"              \
                                          ontop_batch="$ONTOP_BATCH"                        \
                                          ontop_page_size="$ONTOP_PAGE_SIZE"                \
                                          ontop_flush_count="$ONTOP_FLUSH_COUNT"            \
                                          ontop_merge="$ONTOP_MERGE"                        \
                                          ontop_query="$ONTOP_QUERY"                        \
                                          ontop_fragment="$ONTOP_FRAGMENT"                  \
                                          ontop_log_level=$ONTOP_LOG_LEVEL                  \
                                                                                            \
                                          corese_xms="$CORESE_XMS"                          \
                                          corese_xmx="$CORESE_XMX"                          \
                                          corese_query="$CORESE_QUERY"                      \
                                          corese_peek="$CORESE_PEEK"                        \
                                          corese_fragment="$CORESE_FRAGMENT"                \
                                          corese_flush_count="$CORESE_FLUSH_COUNT"          \
                                          corese_format="$CORESE_FORMAT"                    \
                                          "$CORESE_IGNORE_BREAK_LINE"
                                          
        done 
        
        $SCRIPT_PATH/02_build_config.sh  ip=$IP_HOST namespace=$NAME_SPACE rw=$RW ro=$RO 
         
        $SCRIPT_PATH/11_nano_start_stop.sh start rw 12 12 28
   
        echo
        echo
        echo 
        echo -e "\e[93m ######################################################################## \e[32m "
        echo -e "\e[93m ######################################################################## \e[32m "
        echo -e "\e[93m ######## LOADING SYNTHESIS DATA ######################################## \e[32m "
        echo -e "\e[93m ######################################################################## \e[32m "
        echo -e "\e[93m ######################################################################## \e[32m "
        echo 
        echo       

        for SI in `ls "$SI_PATHS" --ignore "ontology" --ignore "SI.txt" `;  do

           if [ -d "$SI_PATHS/$SI/output/04_synthesis/" ] ; then 
          
              $SCRIPT_PATH/09_load_data.sh from_directory="$SI_PATHS/$SI/output/04_synthesis/" \
                                           content_type="text/turtle"           
           fi

        done          
         
        $SCRIPT_PATH/11_nano_start_stop.sh stop
                  
        $SCRIPT_PATH/11_nano_start_stop.sh start ro 12 12 28
  
        ## read -rsn1        
        
    else 
           ./synthesis_extractor_process.sh ip="$IP_HOST"                                     \
                                            namespace="$NAME_SPACE"                           \
                                            ro=$RO                                            \
                                            rw=$RW                                            \
                                            si=$SI                                            \
                                            db=$DATA_BASE                                     \
                                            ext_obda=$EXT_OBDA                                \
                                            ext_graph=$EXT_GRAPH                              \
                                            class_file_name=$CLASS_FILE_NAME                  \
                                            sparql_file_name=$SPARQL_FILE_NAME                \
                                            csv_file_name=$INPUT_CSV_FILE_NAME                \
                                            valide_csv_file_name=$OUTPUT_VALIDE_CSV_FILE_NAME \
                                            csv_sep=$CSV_SEP                                  \
                                            intra_separators="$INTRA_CSV_SEP"                 \
                                            columns="$COLUMNSTO_VALIDATE"                     \
                                            connec_file_name=$CONNEC_FILE_NAME                \
                                                                                              \
                                            ontop_xms="$ONTOP_XMS"                            \
                                            ontop_xmx="$ONTOP_XMX"                            \
                                            ontop_ttl_format="$ONTOP_TTL_FORMAT"              \
                                            ontop_batch="$ONTOP_BATCH"                        \
                                            ontop_page_size="$ONTOP_PAGE_SIZE"                \
                                            ontop_flush_count="$ONTOP_FLUSH_COUNT"            \
                                            ontop_merge="$ONTOP_MERGE"                        \
                                            ontop_query="$ONTOP_QUERY"                        \
                                            ontop_fragment="$ONTOP_FRAGMENT"                  \
                                            ontop_log_level=$ONTOP_LOG_LEVEL                  \
                                                                                              \
                                            corese_xms="$CORESE_XMS"                          \
                                            corese_xmx="$CORESE_XMX"                          \
                                            corese_query="$CORESE_QUERY"                      \
                                            corese_peek="$CORESE_PEEK"                        \
                                            corese_fragment="$CORESE_FRAGMENT"                \
                                            corese_flush_count="$CORESE_FLUSH_COUNT"          \
                                            corese_format="$CORESE_FORMAT"                    \
                                            "$CORESE_IGNORE_BREAK_LINE"
                                        
       
           $SCRIPT_PATH/02_build_config.sh  ip=$IP_HOST namespace=$NAME_SPACE rw=$RW ro=$RO 
         
           $SCRIPT_PATH/11_nano_start_stop.sh start rw 12 12 28
           
           echo
           echo
           echo 
           echo -e "\e[93m ######################################################################## \e[32m "
           echo -e "\e[93m ######################################################################## \e[32m "
           echo -e "\e[93m ######## LOADING SYNTHESIS DATA ######################################## \e[32m "
           echo -e "\e[93m ######################################################################## \e[32m "
           echo -e "\e[93m ######################################################################## \e[32m "
           echo 
           echo
         
           if [ -d "$SI_PATHS/$SI/output/04_synthesis/" ] ; then 
          
             $SCRIPT_PATH/09_load_data.sh  from_directory="$SI_PATHS/$SI/output/04_synthesis/" \
                                           content_type="text/turtle"           
           fi
         
           echo
           
           $SCRIPT_PATH/11_nano_start_stop.sh stop
                  
           $SCRIPT_PATH/11_nano_start_stop.sh start ro 12 12 28
  
           ## read -rsn1
        
    fi
    
