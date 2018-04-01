# homebrew-pymol
A dedicated hombrew tap for my PyMol 2.1 with only Qt and Mac support.

# How to use this tap.

This tap provides only support for QT but not X11/Tkinter. So you need
to install PyQt5 to make your pymol work. The PyQt5 package could be
installed prior to or after installing pymol. It doesn't matter.

We recommend you to install PyQt5 via pip.

If you install python3 via brew, then you can use the following
command to install PyQt5 and pymol.

```
pip3 install PyQt5
brew tap AmzelLab/homebrew-pymol
brew install pymol
```
