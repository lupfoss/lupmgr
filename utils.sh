# utility functions
# use in other script with the following line:
#       source utils.sh
#
# uncomment out main at the bottom of this file to test this locally


log_success() {
    printf "${GREEN}✔ $1${NC}\n" 1>&2
}

log_step() {
    printf "${BLUE}⚙  $1${NC}\n" 1>&2
}

log_fail() {
    printf "${RED}$1${NC}\n" 1>&2
}

log_warn() {
    printf "${YELLOW}$1${NC}\n" 1>&2
}

function require_root_user() {
    local user="$(id -un 2>/dev/null || true)"
    if [ "$user" != "root" ]; then
        log_fail "error - run as root"
        exit 1
    fi
}

LSB_DIST=
DIST_VERSION=
DIST_VERSION_MAJOR=
detect_lsb_dist() {
    _dist=
    _error_msg="We have checked /etc/os-release and /etc/centos-release files."
    if [ -f /etc/centos-release ] && [ -r /etc/centos-release ]; then
        # CentOS 6
        # CentOS 7
        _dist="$(cat /etc/centos-release | cut -d" " -f1)"
        _version="$(cat /etc/centos-release | sed 's/Linux //' | cut -d" " -f3 | cut -d "." -f1-2)"
    elif [ -f /etc/os-release ] && [ -r /etc/os-release ]; then
        _dist="$(. /etc/os-release && echo "$ID")"
        _version="$(. /etc/os-release && echo "$VERSION_ID")"
    elif [ -f /etc/redhat-release ] && [ -r /etc/redhat-release ]; then
        # RHEL6
        _dist="rhel"
        _major_version=$(cat /etc/redhat-release | cut -d" " -f7 | cut -d "." -f1)
        _minor_version=$(cat /etc/redhat-release | cut -d" " -f7 | cut -d "." -f2)
        _version=$_major_version
    elif [ -f /etc/system-release ] && [ -r /etc/system-release ]; then
        if grep --quiet "Amazon Linux" /etc/system-release; then
            # Amazon 2014.03
            _dist="amzn"
            _version=`awk '/Amazon Linux/{print $NF}' /etc/system-release`
        fi
    else
        _error_msg="$_error_msg\nDistribution cannot be determined because neither of these files exist."
    fi

    if [ -n "$_dist" ]; then
        _error_msg="$_error_msg\nDetected distribution is ${_dist}."
        _dist="$(echo "$_dist" | tr '[:upper:]' '[:lower:]')"
        case "$_dist" in
            ubuntu)
                _error_msg="$_error_msg\nHowever detected version $_version is less than 12."
                oIFS="$IFS"; IFS=.; set -- $_version; IFS="$oIFS";
                [ $1 -ge 12 ] && LSB_DIST=$_dist && DIST_VERSION=$_version && DIST_VERSION_MAJOR=$1
                ;;
            debian)
                _error_msg="$_error_msg\nHowever detected version $_version is less than 7."
                oIFS="$IFS"; IFS=.; set -- $_version; IFS="$oIFS";
                [ $1 -ge 7 ] && LSB_DIST=$_dist && DIST_VERSION=$_version && DIST_VERSION_MAJOR=$1
                ;;
            fedora)
                _error_msg="$_error_msg\nHowever detected version $_version is less than 21."
                oIFS="$IFS"; IFS=.; set -- $_version; IFS="$oIFS";
                [ $1 -ge 21 ] && LSB_DIST=$_dist && DIST_VERSION=$_version && DIST_VERSION_MAJOR=$1
                ;;
            rhel)
                _error_msg="$_error_msg\nHowever detected version $_version is less than 7."
                oIFS="$IFS"; IFS=.; set -- $_version; IFS="$oIFS";
                [ $1 -ge 6 ] && LSB_DIST=$_dist && DIST_VERSION=$_version && DIST_VERSION_MAJOR=$1
                ;;
            centos)
                _error_msg="$_error_msg\nHowever detected version $_version is less than 6."
                oIFS="$IFS"; IFS=.; set -- $_version; IFS="$oIFS";
                [ $1 -ge 6 ] && LSB_DIST=$_dist && DIST_VERSION=$_version && DIST_VERSION_MAJOR=$1
                ;;
            amzn)
                _error_msg="$_error_msg\nHowever detected version $_version is not one of\n    2, 2.0, 2018.03, 2017.09, 2017.03, 2016.09, 2016.03, 2015.09, 2015.03, 2014.09, 2014.03."
                [ "$_version" = "2" ] || [ "$_version" = "2.0" ] || \
                [ "$_version" = "2018.03" ] || \
                [ "$_version" = "2017.03" ] || [ "$_version" = "2017.09" ] || \
                [ "$_version" = "2016.03" ] || [ "$_version" = "2016.09" ] || \
                [ "$_version" = "2015.03" ] || [ "$_version" = "2015.09" ] || \
                [ "$_version" = "2014.03" ] || [ "$_version" = "2014.09" ] && \
                LSB_DIST=$_dist && DIST_VERSION=$_version && DIST_VERSION_MAJOR=$_version
                ;;
            sles)
                _error_msg="$_error_msg\nHowever detected version $_version is less than 12."
                oIFS="$IFS"; IFS=.; set -- $_version; IFS="$oIFS";
                [ $1 -ge 12 ] && LSB_DIST=$_dist && DIST_VERSION=$_version && DIST_VERSION_MAJOR=$1
                ;;
            ol)
                _error_msg="$_error_msg\nHowever detected version $_version is less than 6."
                oIFS="$IFS"; IFS=.; set -- $_version; IFS="$oIFS";
                [ $1 -ge 6 ] && LSB_DIST=$_dist && DIST_VERSION=$_version && DIST_VERSION_MAJOR=$1
                ;;
            *)
                _error_msg="$_error_msg\nThat is an unsupported distribution."
                ;;
        esac
    fi

    if [ -z "$LSB_DIST" ]; then
        echo >&2 "$(echo | sed "i$_error_msg")"
        echo >&2 "Contact Lightup support support@lightup.ai"
        exit 1
    else
        echo $LSB_DIST
        echo $DIST_VERSION
    fi
}

is_valid_ipv4() {
    if echo "$1" | grep -qs '^[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$'; then
        return 0
    else
        return 1
    fi
}

is_valid_ipv6() {
    if echo "$1" | grep -qs "^\([0-9a-fA-F]\{0,4\}:\)\{1,7\}[0-9a-fA-F]\{0,4\}$"; then
        return 0
    else
        return 1
    fi
}


discover_public_ip() {
    # gce
    set +e
    _out=$(curl --noproxy "*" --max-time 5 --connect-timeout 2 -qSfs -H 'Metadata-Flavor: Google' http://169.254.169.254/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip 2>/dev/null)
    _status=$?
    set -e
    if [ "$_status" -eq "0" ] && [ -n "$_out" ]; then
        if is_valid_ipv4 "$_out" || is_valid_ipv6 "$_out"; then
            PUBLIC_ADDRESS=$_out
            echo $PUBLIC_ADDRESS
        fi
        return
    fi

    # ec2
    set +e
    _out=$(curl --noproxy "*" --max-time 5 --connect-timeout 2 -qSfs http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null)
    _status=$?
    set -e
    if [ "$_status" -eq "0" ] && [ -n "$_out" ]; then
        if is_valid_ipv4 "$_out" || is_valid_ipv6 "$_out"; then
            PUBLIC_ADDRESS=$_out
            echo $PUBLIC_ADDRESS
        fi
        return
    fi

    # azure
    set +e
    _out=$(curl --noproxy "*" --max-time 5 --connect-timeout 2 -qSfs -H Metadata:true "http://169.254.169.254/metadata/instance/network/interface/0/ipv4/ipAddress/0/publicIpAddress?api-version=2017-08-01&format=text" 2>/dev/null)
    _status=$?
    set -e
    if [ "$_status" -eq "0" ] && [ -n "$_out" ]; then
        if is_valid_ipv4 "$_out" || is_valid_ipv6 "$_out"; then
            PUBLIC_ADDRESS=$_out
            echo $PUBLIC_ADDRESS
        fi
        return
    fi
}

discover_private_ip() {
    # assume eth0 is the private IP address
    set +e
    _out="$(ifconfig | grep -A 1 'eth0' | tail -1 | cut -d ':' -f 2 | cut -d ' ' -f 1)"
    _status=$?
    set -e
    if [ "$_status" -eq "0" ] && [ -n "$_out" ]; then
        if is_valid_ipv4 "$_out" || is_valid_ipv6 "$_out"; then
            PRIVATE_ADDRESS=$_out
            echo $PRIVATE_ADDRESS
        fi
        return
    fi    
}

# uncomment this to run as a standalone script for testing

# main() {
#     require_root_user
#     detect_lsb_dist
#     discover_private_ip
#     discover_public_ip
# }

# main "$@"
