function print_prefix(prefix, count, status) {
  printf "%-20s%-10s%s\n", prefix, count, status
}

function d2b(d, b) {
  while(d) {
    b=d%2b
    d=int(d/2)
  }
  return b
}

function ip2dec(prefix) {
  split(prefix, splitted_prefix, ".")
  b1 = splitted_prefix[1] * 256^3
  b2 = splitted_prefix[2] * 256^2
  b3 = splitted_prefix[3] * 256
  b4 = splitted_prefix[4]
  return b1 + b2 + b3 + b4
}

function dec2ip(dec_prefix) {
  b1 = int(dec_prefix/256^3) % 256
  b2 = int(dec_prefix/256^2) % 256
  b3 = int(dec_prefix/256) % 256
  b4 = int(dec_prefix) % 256
  return b1 "." b2 "." b3 "." b4
}

function compute_prefix(prefix, count, status, count_alloc) {
  split(prefix, bytes, ".")

  # Everything in 151.216.0.0/13 is reserved for temporary assignments
  if(bytes[1] == 151 && bytes[2] >= 216 && bytes[2] <= 223) {
    return 0
  }

  # Everything in 185.0.0.0/15 is reserved for IXP assignments
  if(bytes[1] == 185 && bytes[2] <= 1) {
    return 0
  }

  for(i = 4; i >= 0; i--) {
    if(bytes[i] != 0) {
      bin = d2b(bytes[i])
      idx = match(bin, /0*$/)
      host_bytes = 1 substr(bin, idx, 9 - idx)
      split(host_bytes, msb, "")
      max_count = 2^(length(msb) - 1) * 256 ^ (4 - i)
      if(max_count > count) {
        max_count = count
      }
      cidr = 32 - log(max_count)/log(2)
      remainder = count - max_count
      if(cidr <= 24) {
        print_prefix(prefix "/" cidr, max_count, status)
        count_alloc = count_alloc + 2^(24-cidr)
      }

      if(remainder > 0) {
        new_prefix = dec2ip(ip2dec(prefix) + max_count)
        count_alloc = count_alloc + compute_prefix(new_prefix, remainder, status, count_alloc)
      }
      return count_alloc
    }
  }
}

BEGIN {
  FS = "|"
  print_prefix("Prefix", "Addresses", "Status")
  count_alloc = 0
}
$3 == "ipv4" && $7 ~ /(reserved|available)/ && $5 >= 256 {
  count_alloc = compute_prefix($4, $5, $7, count_alloc)
}
END {
  print "Number of /24 available for future allocation: " count_alloc
}
