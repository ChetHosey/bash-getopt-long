GETOPT_LONG_VERSION=0.01
GETOPT_LONG_SOURCE_DIRECTORY=/etnnfs/j2ee/scripts/snippets

GETOPT_LONG_ARG_NONE=0
GETOPT_LONG_ARG_OPTIONAL=1
GETOPT_LONG_ARG_REQUIRED=2

declare -A _GETOPT_LONG_LONGOPT_ARG_OPTION
declare -A _GETOPT_LONG_SHORTOPT_ARG_OPTION

declare -a _GETOPT_LONG_ARGV
declare -i _GETOPT_LONG_ARG_INDEX

function log_msg
{
	[[ -w "$LOGFILE" ]] || touch "$LOGFILE"
	[[ -w "$LOGFILE" ]] || return

	local type="$1"
	shift
	local msg="$*"
	echo "`date` :: $type :: $msg" >> "$LOGFILE"
}

function getopt_long_check_update() {
	local ME="$(basename "$BASH_SOURCE")"

	if [ -d "$GETOPT_LONG_SOURCE_DIRECTORY" ] && [ -f "$GETOPT_LONG_SOURCE_DIRECTORY/$ME" ]; then
		local AVAILABLEVERSION=`egrep "^VERSION=" $GETOPT_LONG_VERSION/$ME | cut -d'=' -f2 | tr -d '"'`
		local FRESHVERSION=`echo "if( $AVAILABLEVERSION > $VERSION ){ \"updatemeplz\" }" | bc`
		if [ "$FRESHVERSION" = "updatemeplz" ]; then
			echo "Version $AVAILABLEVERSION of $ME is available."
			log_msg "INFO" "Version $AVAILABLEVERSION of $ME is available."
			return 1
		fi
	fi
	return 0
}

function _gol_reset {
	_GETOPT_LONG_LONGOPT_ARG_OPTION=()
	_GETOPT_LONG_SHORTOPT_ARG_OPTION=()

	_GETOPT_LONG_ARGV=( "${@}" )
	_GETOPT_LONG_ARG_INDEX=0
}
_gol_reset "${@}"

function add_long_option {
	case "$#" in
		1)
			_GETOPT_LONG_LONGOPT_ARG_OPTION["$1"]="$GETOPT_LONG_ARG_NONE"
			;;
		2)
			_GETOPT_LONG_LONGOPT_ARG_OPTION["$1"]="$2"
			;;
		*)
			echo "Could not add long option, wrong argument count ($#): $*" >&2 
			exit 1;
			;;
	esac
}

function add_short_option {
	case "$#" in
		1)
			_GETOPT_LONG_SHORTOPT_ARG_OPTION["$1"]="$GETOPT_LONG_ARG_NONE"
			;;
		2)
			_GETOPT_LONG_SHORTOPT_ARG_OPTION["$1"]="$2"
			;;
		*)
			echo "Could not add short argument, wrong argument count ($#): $*" >&2 
			exit 1;
			;;
	esac
}

_GOL_PATTERN_SHORT_BUNDLED_OPTION='^-([^-=])([^-=]{1,}(=.*)?)$'
_GOL_PATTERN_SHORT_OPTION='^-([^-=])(=(.*))?$'
_GOL_PATTERN_LONG_OPTION='^--([^-=][^=]*)(=(.*))?$'

function _gol_set_opts {
	local _gol_arg="$1"
	local _gol_opt_expr="$2"
	local _gol_value="$3"
	local _gol_required_flag="$4"
	local _gol_option_prefix="$5"

	case "$_gol_required_flag" in
		$GETOPT_LONG_ARG_OPTIONAL)
			printf -v "$_gol_option_variable" "%s" "${_gol_arg}"
			printf -v "$_gol_argument_variable" "%s" "${_gol_value}"
			;;
		$GETOPT_LONG_ARG_REQUIRED)
		if [[ ! -z ${_gol_opt_expr} ]]
			then
				printf -v "$_gol_option_variable" "%s" "${_gol_arg}"
				printf -v "$_gol_argument_variable" "%s" "${_gol_value}"
			else
				_GETOPT_LONG_ARG_INDEX=$(( $_GETOPT_LONG_ARG_INDEX + 1 ))
				if [[ $_GETOPT_LONG_ARG_INDEX -ge ${#_GETOPT_LONG_ARGV[@]} ]]
				then
					if [[ $OPTERR ]]
					then
						[[ $OPTERR ]] && echo "Warning: no argument supplied for ${_gol_option_prefix}$_GOL_CURRENT_OPTION" >&2
					fi
					printf -v "$_gol_option_variable" "?"
					printf -v "$_gol_argument_variable" "%s" "${_gol_arg}"
				else
					printf -v "$_gol_option_variable" "%s" "${_gol_arg}"
					printf -v "$_gol_argument_variable" "%s" "${_GETOPT_LONG_ARGV[$_GETOPT_LONG_ARG_INDEX]}"
				fi
			fi
			;;
		*)
			if [[ ! -z ${_gol_value} ]]
			then
				[[ $OPTERR ]] && echo "Warning: argument to -$_GOL_CURRENT_OPTION ignored" >&2
			fi
			printf -v "$_gol_option_variable" "%s" "${_gol_arg}"
			printf -v "$_gol_argument_variable" "%s" ""
			;;
	esac
}

function getopt_long {
	_gol_option_variable=$1
	_gol_argument_variable=$2

	if [[ $_GETOPT_LONG_ARG_INDEX -ge ${#_GETOPT_LONG_ARGV[@]} ]]
	then
		printf -v "$_gol_option_variable" "%s" ""
		printf -v "$_gol_argument_variable" "%s" ""
		return 1
	fi

	local _GOL_CURRENT_ARG="${_GETOPT_LONG_ARGV[$_GETOPT_LONG_ARG_INDEX]}"
	if [[ $_GOL_CURRENT_ARG =~ $_GOL_PATTERN_SHORT_BUNDLED_OPTION ]]
	then
		_GOL_CURRENT_OPTION="${BASH_REMATCH[1]}"
		_GETOPT_LONG_ARGV[$_GETOPT_LONG_ARG_INDEX]="-${BASH_REMATCH[2]}"

		if [[ ${_GETOPT_LONG_SHORTOPT_ARG_OPTION["$_GOL_CURRENT_OPTION"]+isset} ]]
		then
			printf -v "$_gol_option_variable" "%s" "${BASH_REMATCH[1]}"
			printf -v "$_gol_argument_variable" "%s" ""
		else
			printf -v "$_gol_option_variable" "?"
			printf -v "$_gol_argument_variable" "$_GOL_CURRENT_OPTION"
		fi

	elif [[ $_GOL_CURRENT_ARG =~ $_GOL_PATTERN_SHORT_OPTION ]]
	then
		_GOL_CURRENT_OPTION="${BASH_REMATCH[1]}"

		if [[ ${_GETOPT_LONG_SHORTOPT_ARG_OPTION["$_GOL_CURRENT_OPTION"]+isset} ]]
		then
			_gol_set_opts "$_GOL_CURRENT_OPTION" \
				"${BASH_REMATCH[2]}" \
				"${BASH_REMATCH[3]}" \
				"${_GETOPT_LONG_SHORTOPT_ARG_OPTION["$_GOL_CURRENT_OPTION"]}" \
				'--'
		else
			printf -v "$_gol_option_variable" "?"
			printf -v "$_gol_argument_variable" "$_GOL_CURRENT_OPTION"
		fi

		_GETOPT_LONG_ARG_INDEX=$(( $_GETOPT_LONG_ARG_INDEX + 1 ))
	elif [[ $_GOL_CURRENT_ARG =~ $_GOL_PATTERN_LONG_OPTION ]]
	then
		_GOL_CURRENT_OPTION="${BASH_REMATCH[1]}"
		if [[ ! ${_GETOPT_LONG_LONGOPT_ARG_OPTION["$_GOL_CURRENT_OPTION"]+isset} ]]
		then
			local -a MATCHES=()
			local key
			for key in "${!_GETOPT_LONG_LONGOPT_ARG_OPTION[@]}"
			do
				[[ $key == $_GOL_CURRENT_OPTION* ]] && MATCHES+=("$key")
			done
			if [[ "${#MATCHES[@]}" -eq 1 ]]
			then
				_GOL_CURRENT_OPTION="${MATCHES[0]}"
			else
				local OFS
				OFS=', '
				if [[ $OPTERR ]]
				then
					echo "Warning: argument $_GOL_CURRENT_ARG is ambiguous, possible options are:" >&2
					echo
					for key in "${MATCHES[@]}"
					do
						echo -e "\t--${key}" >&2
					done
					echo
				fi
			fi
		fi

		if [[ ${_GETOPT_LONG_LONGOPT_ARG_OPTION["$_GOL_CURRENT_OPTION"]+isset} ]]
		then
			_gol_set_opts "$_GOL_CURRENT_OPTION" \
				"${BASH_REMATCH[2]}" \
				"${BASH_REMATCH[3]}" \
				"${_GETOPT_LONG_LONGOPT_ARG_OPTION["$_GOL_CURRENT_OPTION"]}" \
				'--'
		else
			printf -v "$_gol_option_variable" "?"
			printf -v "$_gol_argument_variable" "$_GOL_CURRENT_OPTION"
		fi

		_GETOPT_LONG_ARG_INDEX=$(( $_GETOPT_LONG_ARG_INDEX + 1 ))
	else
		[[ $OPTERR ]] && echo "Warning: skipping non-option $_GOL_CURRENT_ARG" >&2
		_GETOPT_LONG_ARG_INDEX=$(( $_GETOPT_LONG_ARG_INDEX + 1 ))
	fi

	return 0
}
