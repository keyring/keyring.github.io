% Based on the original idea by Friggeri found at
% http://www.latextemplates.com/template/friggeri-resume-cv
% Must be compiled using XeLatex (FontAwesome)

\LoadClass[12pt]{article}
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{rvca_print}[2014/05/04 RVCA CV class]

%% Options, full prints out full work items
\newcommand{\@full}{0}
\DeclareOption{full}{ 
  \renewcommand{\@full}{1}
}
\DeclareOption*{%
  \PackageWarning{rvca}{Unknown option `\CurrentOption'}%
}
\ProcessOptions\relax


%Class requirements
\RequirePackage{titlesec}
\RequirePackage{xcolor}
\RequirePackage{tikz}
\usetikzlibrary{shapes}
\RequirePackage{ifthen}
\RequirePackage{fontawesome}
\RequirePackage{fontspec}
\RequirePackage{xeCJK}


%%%
%%% Configuration 
%%%

%Color of links and header box
\definecolor{bandcolor}{RGB}{255,102,0} %WEBSITECOLOR
 \definecolor{themecolor}{RGB}{20,20,20}
% \definecolor{themecolor}{RGB}{255,102,0}
 \definecolor{linkcolor}{RGB}{109,62,0}
% \definecolor{themecolor}{RGB}{0,102,204}

 \definecolor{sidebandcolor}{RGB}{255,255,255}
% \definecolor{sidebandcolor}{RGB}{61,60,58}

%\definecolor{sidebandtextcolor}{RGB}{255,255,255}
\definecolor{sidebandtextcolor}{RGB}{61,60,58}

%\definecolor{bandcolor}{RGB}{251,168,39}
\definecolor{titlecolor}{RGB}{61,60,58}
%\definecolor{linkcolor}{RGB}{112,112,112}


%\setCJKmainfont[BoldFont=SimHei]{Microsoft YaHei}
\setCJKmonofont{Microsoft YaHei}% 设置缺省中文字体
%%%
%%% General settings 
%%%



%Margin settings
\RequirePackage[left=5.8cm,top=2.0cm,right=1.2cm,bottom=1.2cm,nohead,nofoot]{geometry} 

%Hyperlinks
\RequirePackage[colorlinks = true,
            linkcolor = linkcolor,
            urlcolor  = linkcolor,
            citecolor = linkcolor,
            anchorcolor = linkcolor]{hyperref}
% Using verdana font
\renewcommand{\rmdefault}{pag} %PDFLatex Verdana
\setmainfont{Liberation Sans} %Xelatex 

% Remove page numbers
\pagestyle{empty} 

% Redefinition, symbol included in link:
\let\orighref\href
\renewcommand{\href}[2]{\orighref{#1}{#2\,\scriptsize{\faLink} }}


%%%
%%% Name Header
%%%

\newcommand{\header}[3]{
  \begin{tikzpicture}[remember picture,overlay]
  \node [rectangle, anchor=west, minimum width=5.5cm, minimum height=5.7cm, xshift=0cm,yshift=-3.2cm] (box) at (current page.north west){};
    \node [anchor=north] (avataricon) at (box.north) {#1};
    \node [anchor=north] (name) at (avataricon.south) {
      \fontsize{28pt}{12pt}\color{sidebandtextcolor}\selectfont #2
%      \huge \color{white} #2
    };
    \node [anchor=south] at (box.south) {
      \fontsize{14pt}{24pt}\color{sidebandtextcolor}\selectfont #3
      %\large \color{white} #3
    };
  \end{tikzpicture}
  \vspace{2.5cm}
  \vspace{-2\parskip}
}


%%%
%%% Aside Panel for contact info
%%%

\RequirePackage[absolute,overlay]{textpos}
\setlength{\TPHorizModule}{1cm}
\setlength{\TPVertModule}{1cm}
\newenvironment{aside}{
      %Draw side band
      \begin{tikzpicture}[remember picture,overlay]
	\node [rectangle, fill=sidebandcolor, anchor=west, minimum width=5.5cm, minimum height=\paperheight] (box) at (current page.west){};
      \end{tikzpicture}
      \let\oldsection\section
      \renewcommand{\section}[1]{
	    \par\vspace{\baselineskip}{\Large ##1}
      }
      \begin{textblock}{5}(0.3, 3.5)
      \begin{flushright}
      \color{sidebandtextcolor}
      \obeycr
}{
  \restorecr
  \end{flushright}
  \end{textblock}
  \let\section\oldsection
}

%%%
%%% Statement Panel for a brief mision statement
%%%

\newenvironment{statement}{
  \let\oldsection\section
  \renewcommand{\section}[1]{
    \par\vspace{\baselineskip}{\LARGE ##1}
  }
  \begin{textblock}{14}(6.3, 1.2)
  \noindent
  \obeycr
}{
  \restorecr
  \end{textblock}
  \let\section\oldsection
}


%%%
%%% Sections and Subsections
%%%

\titleformat{\section}         % Customise the \section command 
{\color{titlecolor}\Large\raggedright\bfseries}   % Make the \section headers large (\Large),
                               % small capitals (\scshape) and left aligned (\raggedright)
{}{0em}                        % Can be used to give a prefix to all sections, like 'Section ...'
{\uppercase}                             % Can be used to insert code before the heading
[\color{titlecolor}{\titlerule[3pt]}] % Inserts a horizontal line after the heading

%Subtitles  
\titleformat{\subsection}
{\large\scshape\raggedright}
{}{0em}
{}

\newcommand{\datedsection}[2]{%
  \section[#1]{#1 \hfill #2}%
}
\newcommand{\datedsubsection}[2]{%
  \subsection[#1]{#1 \hfill #2}%
}

%Subtitles
\titleformat{\subsection}
{\large\scshape\raggedright}
{}{0em}
{}

%Subsubtitles
\titleformat{\subsubsection}
{\normalsize\raggedright}
{}{0em}
{}



%%%
%%% Work Items
%%%

% \workitem
% {}%Company
% {}%Title
% {}%Dates
% {}%Responsibilities
% {}%Achievement(1)
% {}%Achievement(2)
% {}%Achievement(3)

% A Function that prints out:
% the first argument if empty, the second argument if it exists
\def\IfEmptyTF#1{%
  \if\relax\detokenize{#1}\relax
    \expandafter\@firstoftwo
  \else
    \expandafter\@secondoftwo
  \fi}

\newcommand{\workitem}[8]{
  \subsection[#1]{#1 \hfill #2}%
   \subsubsection {#3}%
  \ifthenelse{\@full=1}{%
    {\small #4}%
    {\small
     \begin{itemize}%
       \item #5%
       \IfEmptyTF{#6}{}{\item #6}%
       \IfEmptyTF{#7}{}{\item #7}%
       \IfEmptyTF{#8}{}{\item #8}%
     \end{itemize}
    }
  }{}%
}

\newcommand{\educationitem}[4]{
  \subsection[#1]{#1 \hfill #2}%
   \subsubsection {#3}%
  \ifthenelse{\@full=1}{%
    {\small #4}%
  }{}%
}


\newcommand{\achievements}[5]{
   \small\begin{itemize}%
       \item [\NinjaIcon] #1%
       \IfEmptyTF{#2}{}{\item [\NinjaIcon] #2}%
       \IfEmptyTF{#3}{}{\item [\NinjaIcon] #3}%
       \IfEmptyTF{#4}{}{\item [\NinjaIcon] #4}%
       \IfEmptyTF{#5}{}{\item [\NinjaIcon] #5}%
     \end{itemize}
}

%%%
%%% A riddle at the end of page 2, if full enabled
%%%
\newenvironment{riddle}{
  \ifthenelse{\@full=1}{%
    % Experimental side panel on second pagea
    %Draw side band
    \begin{tikzpicture}[remember picture,overlay]
      \node [rectangle, fill=sidebandcolor, anchor=north west, minimum width=5.5cm, minimum height=2cm] (box) at (current page.north west){};
    \end{tikzpicture}
    \begin{textblock}{4.2}(0.6, 2.5)
    \begin{flushright}
    \QrCode
    \end{flushright}
    \end{textblock}
    \begin{textblock}{4.3}(0.9, 25.0)
    \scriptsize \centering A riddle to take away: What happens once every minute, twice every moment and not once in a thousand years?
    \end{textblock}
  }
}

%%%
%%% Images (power-ups like unicorns and ninjas, and QRCode)
%%%
\newcommand*{\AvatarIcon}{\includegraphics[scale=0.5]{img/AvatarIcon}}%
\newcommand*{\HomeIcon}{\includegraphics[scale=0.05]{img/HomeIcon}}%
\newcommand*{\EmailIcon}{\includegraphics[scale=0.05]{img/EmailIcon}}%
\newcommand*{\PhoneIcon}{\includegraphics[scale=0.5]{img/PhoneIcon}}%
\newcommand*{\GithubIcon}{\includegraphics[scale=0.05]{img/GithubIcon}}%
\newcommand*{\LinkedinIcon}{\includegraphics[scale=0.05]{img/LinkedinIcon}}%

\newcommand*{\HeartIcon}{\includegraphics[scale=0.04]{img/HeartIcon}}%
\newcommand*{\UnicornIcon}{\includegraphics[scale=0.08]{img/UnicornIcon}}%
\newcommand*{\NinjaIcon}{\includegraphics[scale=0.3]{img/NinjaIcon}}

\newcommand*{\QrCode}{\includegraphics[scale=0.7]{img/qrcode}}
\newcommand*{\ghost}{\includegraphics[scale=1.0]{img/ghost}} %Empty image generating space