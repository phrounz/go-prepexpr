package main

// required for code snipped using strconv:
// prepexpr:import:strconv

// required for SortSlice:
// prepexpr:import:sort

import (
	"fmt"

	"./prepexpr"
)

func main() {

	var value = 2

	// IgnoreUnused allows ignoring the compilation error stating that value is
	// not used when it is used in snipped codes. (It is actually replaced by
	// nothing in the generated code.)
	prepexpr.IgnoreUnused(value)

	// Eval evaluates a code snippet. Second argument evaluation is returned.
	// (In this example "value" is actually modified to be 12 at the end.)
	fmt.Printf("test value  : %d\n", prepexpr.Eval("value+=10", "value+1").(int))

	var slice1 = []int{1, 3, 2}

	// Ternary is a ternary operator, like (condition?truthy:falsey) in C/C++.
	fmt.Printf("test ternary: are there 4 elements ? %s\n", prepexpr.Ternary(len(slice1) == 4, "yes", "no").(string))
	fmt.Printf("test ternary: are there 3 elements ? %s\n", prepexpr.Ternary(len(slice1) == 3, "yes", "no").(string))

	// CloneSlice copies all elements of the input slice into the output slice.
	// (This is not a deep copy though.)
	fmt.Printf("test copy   : %v\n", prepexpr.CloneSlice(slice1).([]int))

	// MapSlice creates a new slice with each element being the result of the expression
	// in the code snippet (in it, "i" is the current element of the input slice).
	fmt.Printf("test map    : %v\n", prepexpr.MapSlice(slice1, "\"#\"+strconv.Itoa(i*2)").([]string))

	// FilterSlice creates a new slice with only the elements satisfying the code snippet
	// expression (in it, "i" is the current element of the input slice).
	fmt.Printf("test filter : %v\n", prepexpr.FilterSlice(slice1, "i >= 2").([]int))

	// FilterSlice creates a new slice with the elements of the input slice sorted using
	// the code snippet (in it, "s" is the slice, "i" and "j" the indexes of the elements
	// to compare).
	fmt.Printf("test sort   : %v\n", prepexpr.SortSlice(slice1, "s[i] < s[j]").([]int))

	var map1 = map[string]int{"foo": 1, "bar": 2}

	// Keys returns the keys of a map.
	fmt.Printf("test keys   : %v\n", prepexpr.Keys(map1).([]string))

	// Values returns the values of a map.
	fmt.Printf("test values : %v\n", prepexpr.Values(map1).([]int))
}
