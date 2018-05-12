## Abstract

Functional programming (FP) provides a rich set of tools for reducing duplication in your code. The goal of FP is make it easy to express repeated actions using high-level verbs.

FP provides a set of tools and more importantly a way of thinking about problems. Helps you to break down a big problem into little pieces. You solve the unique part of your problem and then rely on FP tools to scale up.

There are three keys to using FP effectively:

1. Extract out a small action from a complicated problem . Perform the action
  
   action either locate an existing function or create a new one.
   
2. Identify  Recognise Understand the family of map functions and map your problem to the 
   most appropriate map function

3. Recognise the two "direction" in which you can break down a problem, and to 
   pick the direction (col-wise) that usually makes problems easier to solve


is to make it easy to repeat yourself in code, rather than with copy and paste. FP lends itself to a natural way of solving a wide variety of problems:

* You interactively solve a single instance of a problem
* You use a "map" function to apply your solution to every instance of the problem


In this talk, I'll attempt to give you a sense for what FP is, how it compares to more general tools (like for loops) and how you might use it in your everyday R life, using simple, practical examples.
