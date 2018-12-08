sub fixStrSize {
	my ($str,$size) = @_;

	if ($size<=length($str)) {
		return substr($str,length($str)-size,size);
	}else{
		my $leadings=size-length($str);
		return "0"x$leadings.$str;
	}
}

package Bit;

sub new {
	my ($class, $args) = @_;

	my $self = {
		preamble  => 0b10101010101010101010101010101010101010101010101010101010, # const 7 bytes
		startOfFrame => 0b10101011, # const 1 byte
		scrAddr  => 0, # 6 bytes (MAC)
		dstAddr  => 0, # 6 bytes (MAC)
		length  => 0, # 2 bytes
		data  => "", # 46 bytes <= data <= 1500 bytes
		cyclicRCheck  => 0, # 4 bytes checksum
	};

	return bless $self, $class;
}

sub new_toSend {
	my ($class, $scrAddr, $dstAddr, $data) = @_;

	my $self = $class->new();
	$self->{scrAddr} = $scrAddr; 
	$self->{dstAddr} = $dstAddr;
	$self->{data} = $data; 

	return $self;
}


sub new_toReceive {
	my ($class, $bit) = @_;

	my $self = $class->new();
	$self->{scrAddr} = $scrAddr; 
	$self->{dstAddr} = $dstAddr;
	$self->{data} = $data; 

	return $self;
}


sub toString {
	my $self = shift;

	my $str=fixStrSize(sprintf("%b", $self->{preamble}), 56);
	$str.=fixStrSize(sprintf("%b", $self->{startOfFrame}), 8);
	$str.=fixStrSize(sprintf("%b", $self->{scrAddr}), 48);
	$str.=fixStrSize(sprintf("%b", $self->{dstAddr}), 48);
	$str.=fixStrSize(sprintf("%b", $self->{length}), 16);
	$str.=$self->{data};
	$str.=fixStrSize(sprintf("%b", $self->{cyclicRCheck}), 32);

	return $str;
}

sub toBin {
	my $self = shift;

	my $str="";
	str.=chr($self->{preamble}>>48&0b11111111).chr($self->{preamble}>>40&0b11111111).chr($self->{preamble}>>32&0b11111111).chr($self->{preamble}>>24&0b11111111).chr($self->{preamble}>>16&0b11111111).chr($self->{preamble}>>8&0b11111111).chr($self->{preamble}&0b11111111);
	str.=chr($self->{startOfFrame}&0b11111111);
	str.=chr($self->{scrAddr}>>40&0b11111111).chr($self->{scrAddr}>>32&0b11111111).chr($self->{scrAddr}>>24&0b11111111).chr($self->{scrAddr}>>16&0b11111111).chr($self->{scrAddr}>>8&0b11111111).chr($self->{scrAddr}&0b11111111);
	str.=chr($self->{dstAddr}>>40&0b11111111).chr($self->{dstAddr}>>32&0b11111111).chr($self->{dstAddr}>>24&0b11111111).chr($self->{dstAddr}>>16&0b11111111).chr($self->{dstAddr}>>8&0b11111111).chr($self->{dstAddr}&0b11111111);
	str.=chr($self->{length}>>8&0b11111111).chr($self->{length}&0b11111111);
	str.=chr($self->{cyclicRCheck}>>24&0b11111111).chr($self->{cyclicRCheck}>>16&0b11111111).chr($self->{cyclicRCheck}>>8&0b11111111).chr($self->{cyclicRCheck}&0b11111111);

	return $str;
}


1;


package PhysicalLayer;

my $bite=Bit->new_toSend(10,20,"copa");
print ($bite->{scrAddr});
print ($bite->{dstAddr});
print ($bite->{data});