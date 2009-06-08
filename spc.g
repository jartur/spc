grammar spc;

options
{
	language=CSharp2;
}

@namespace { spc }

prog	:	ID+;
ID	:	('a'..'z')+;
