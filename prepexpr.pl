#!/usr/bin/perl

use strict;
use warnings;

sub unstringify($) {
  my $code_snippet = shift;
  unless ($code_snippet =~ s/^\s*\"(.*)\"\s*$/$1/) {
    die "Code snippet $code_snippet should start and end with \"";
  }
  $code_snippet =~ s/\\\"/\"/g;
  return $code_snippet;
}

sub retrieve3Args {
  my ($input, $code_snippet, $type) = @_;
  return ($input, unstringify($code_snippet), $type);
}

sub processFile($$) {

  my ($input_file, $output_file) = @_;

  my $fn_import = sub ($) {
    my $package = $1;
    return "import \"$package\"";
  };

  my $fn_eval = sub ($$$) {
    my ($code_snippet1, $code_snippet2, $type) = @_;
    $code_snippet1 = unstringify($code_snippet1);
    $code_snippet2 = unstringify($code_snippet2);
    my $separator = (($code_snippet1 ne "") && ($code_snippet2 ne "") ? " ; " : "");
    return "func() $type { $code_snippet1 $separator return $code_snippet2 } ()";
  };

  my $fn_ternary = sub ($$$$) {
    my ($condition, $thruthy, $falsey, $type) = @_;
    return "func() $type {
      if $condition {
        return $thruthy
      }
      return $falsey } () ";
  };

  my $fn_clone = sub ($$) {
    my ($input, $type) = @_;
    return "func() []$type {
      if $input == nil { return nil }
      var out = make([]$type, len($input))
      copy(out, $input)
      return out } () ";
  };

  my $fn_map = sub ($$$) {
    my ($input, $code_snippet, $type) = retrieve3Args(@_);
    return "func() (out []$type) {
      out = make([]$type, 0, len($input))
      for _, i := range $input {
        out = append(out, $code_snippet)
      }
      return out } ()";
  };

  my $fn_filter = sub ($$$) {
    my ($input, $code_snippet, $type) = retrieve3Args(@_);
    return "func() (out []$type) {
      out = make([]$type, 0)
      for _, i := range $input {
        if $code_snippet {
          out = append(out, i)
        }
      }
      return out } ()";
  };

  my $fn_sort = sub ($$$) {
    my ($input, $code_snippet, $type) = retrieve3Args(@_);
    return "func() (s []$type) {
      s = make([]$type, len($input))
      copy(s, $input)
      sort.SliceStable(s, func(i, j int) bool { return $code_snippet })
      return s } ()";
  };

  my $fn_keys = sub ($$) {
    my ($input, $type) = @_;
    return "func() (out []$type) {
      out = make([]$type, 0, len($input))
      for k, _ := range $input {
        out = append(out, k)
      }
      return out } ()";
  };

  my $fn_values = sub ($$) {
    my ($input, $type) = @_;
    return "func() (out []$type) {
      out = make([]$type, 0, len($input))
      for _, v := range $input {
        out = append(out, v)
      }
      return out } ()";
  };

  open (FDR, $input_file) || die "$input_file - $!";
  open (FDW, ">$output_file") || die "$output_file - $!";
  while (<FDR>) {
    $_ =~ s/^\/\/\s*prepexpr\:import\:(.*)$/$fn_import->($1)/eg;
    $_ =~ s/^\s*\".\/prepexpr\"[\s\n]*$//g;
    $_ =~ s/prepexpr\.IgnoreUnused\([a-zA-Z0-9\_\, ]+\)//g;
    $_ =~ s/prepexpr\.Eval\((\".*\")\s*,\s*(\".*?\")\s*\)\.\(([^\)]+)\)/$fn_eval->($1, $2, $3)/eg;
    #$_ =~ s/prepexpr\.EvalWith\((.*?),[a-zA-Z0-9\_\, ]+\)\.\(([^\)]+)\)/$fn_eval->($1, $2)/eg;
    $_ =~ s/prepexpr\.Ternary\((.*?)\s*,\s*(.*?)\s*,\s*(.*?)\s*\)\.\(([^\)]+)\)/$fn_ternary->($1,$2,$3,$4)/eg;
    $_ =~ s/prepexpr\.CloneSlice\((\w+)\)\.\(\[\]([^\)]+)\)/$fn_clone->($1,$2)/eg;
    $_ =~ s/prepexpr\.MapSlice\((\w+)\s*,\s*(\".*?\")\)\.\(\[\]([^\)]+)\)/$fn_map->($1,$2,$3)/eg;
    $_ =~ s/prepexpr\.FilterSlice\((\w+)\s*,\s*(\".*?\")\)\.\(\[\]([^\)]+)\)/$fn_filter->($1,$2,$3)/eg;
    $_ =~ s/prepexpr\.SortSlice\((\w+)\s*,\s*(\".*?\")\)\.\(\[\]([^\)]+)\)/$fn_sort->($1,$2,$3)/eg;
    $_ =~ s/prepexpr\.Keys\((\w+)\)\.\(\[\]([^\)]+)\)/$fn_keys->($1,$2)/eg;
    $_ =~ s/prepexpr\.Values\((\w+)\)\.\(\[\]([^\)]+)\)/$fn_values->($1,$2)/eg;
    print FDW $_;
  }
  close FDR;
  close FDW;

  return 1;
}

processFile($ARGV[0], $ARGV[1]);
exit 0;
