A full comparison of 6 JS libraries for generating PDFs

#javascript #node #typescript #pdf

Introduction

In this article, we’ll talk about a series of Javascript libraries for generating PDFs. We'll look into real-world use cases and we'll mainly focus on 5 things:

the running environment the supported modules typings custom fonts easy to use

After this read, you'll be able to find the right PDF library for your Javascript application. In the end, we'll also introduce pdfme, a very handy and powerful PDF library!

Let's GO pdfme Official Site

if you like it, give me a start⭐ https://github.com/pdfme/pdfme

Comparison

Compare 6 libraries

1. PDFKit

PDFKit is one of the first pdf libraries released in the huge Javascript ecosystem. Available since 2012 has gained strong popularity and it is still receiving updates as of 2021. A little bit more difficult to use if compared to other libraries offers support to both Node and the browser through Webpack.

And as we will see later in this comparison some PDF libraries are wrappers around PDFKit.

It supports custom fonts and image embedding, but lacks of a high- level API;

In addition, the documentation tends to be complex. As you can expect, it requires a certain amount of time to get used to it, and at the very beginning, you'll find that designing PDFs will not be the easiest thing to do.

Point of evaluation Evaluation

Works in Node and browser △(a bit complicated)

Typings ○(DefinitelyTyped)

Custom fonts ○(Be careful when using this in a browser)

Easy to use △(a bit complicated)

2. pdfmake

pdfmake is a wrapper library built around PDFKit. The main the difference is in the programming paradigm:

while PDFKit adopts the classic imperative style, pdfmake has a declarative approach.

That's why it's easier to focus on what you want to do, instead of spending time telling the library how to achieve a determined result.

But not all that glitters is gold, you might encounter issues when you try to embed custom fonts while using Webpack. Unfortunately, there is no much documentation available on the web about this issue. However, if you are not using Webpack you can easily clone the git repository and run the font embedding script.

Point of evaluation Evaluation

Works in Node and browser △(Be careful using Webpack)

Typings ○(DefinitelyTyped)

Custom fonts △(Need to build your own)

Easy to use ○

3. jsPDF

jsPDF has the highest number of start among the pdf libraries in GitHub, and not by chance it’s very stable and well maintained. The modules are exported according to the AMD module standard, which makes easy to use it with node and browsers.

As for PDFKit the APIs provided have an imperative pattern, with the result that creating a complex layout tend to be very hard.

Embedding fonts it’s not difficult but needs an extra step: converting the fonts to TTF files.

jsPDF is not the easiest library to master, but the documentation is very rich so you’ll not encounter any particular obstacle while working with it. https://rawgit.com/MrRio/jsPDF/master/docs/index.html)

Point of evaluation Evaluation

Works in Node and browser ○

Typings ○

Custom fonts ○(ttf files need to be converted)

Easy to use △(a bit complicated)

4. Puppeteer

As you may know, Puppeteer is a Node library that provides a high- level API to control Chrome, but it can also be used to create PDFs as well.

The templates have to be written in HTML, which makes jsPDF very easy to use for web developers.

The following article is a good reference to use while you are developing: Generate a PDF from HTML with puppeteer

Puppeteer has mainly two disadvantages:

You need to implement a backend solution. You need to start Puppeteer every-time you need to create a PDF, which creates some overhead. It is slow.

If the disadvantages listed above are not a big problem for you, then it may be a good option especially if you need to design HTML-tables etc.

Point of evaluation Evaluation

Works in Node and browser x

Typings -

Custom fonts ○(web fonts)

Easy to use ?

5. pdf-lib

pdf-lib is a library for creating and editing PDFs implemented entirely in Typescript, and as for pdfmake is built around PDFKit.

Although it was released after all the other libraries, it’s very popular with thousands of stars on GitHub.

The design of the APIs are awesome and of course, works with both: node and browsers.

It supports PDF merging, splitting, embedding, and has a lot of features that other libraries just don’t have;

pdf-lib is very powerful, but also very simple to use.

One of the hottest features is the support to Unit8Array and ArrayBuffer to embed font files, which allows using fs in case you are working with node and xhr in case you are working in the browser. You’ll be able to feel its superiors in terms of performance when you compare it with other libraries, and of course it can be used with Webpack.

Also, this library has an imperative approach, and as can be deduced working with complex layouts it’s not so easy.

Point of evaluation Evaluation

Works in Node and browser ○

Typings ○

Custom fonts ○

Easy to use △(a bit complicated, the layout needs to be calculated)

6. pdfme

Finally, we are at the end, so let me introduce pdfme. I personally developed this library, with the aim of making Pdf-lib as declarative as possible.

In contraposition with pdf-lib, pdfme doesn’t require the developer to calculate the layout by himself: no need to define every time alignments, line-height, etc.

With the advantages of pdf-lib, such as the ability to use Uint8Array and ArrayBuffer for font data, and the ability to embed PDF files,

pdfme allows developers to create complex layouts efficiently.

You can also try Template Design & Code Generator to design your favorite PDF layout and generate some executable code!

Point of evaluation Evaluation

Works in Node and browser ○

Typings ○

Custom fonts ○

Easy to use ○
