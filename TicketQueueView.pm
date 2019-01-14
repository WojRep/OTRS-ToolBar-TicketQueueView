# --
# Copyright (C) 2019 Actuna
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package Kernel::Output::HTML::ToolBar::TicketQueueView;

use parent 'Kernel::Output::HTML::Base';

use strict;
use warnings;

our @ObjectDependencies = (
    'Kernel::System::Log',
    'Kernel::Config',
    'Kernel::Output::HTML::Layout',
    'Kernel::System::Ticket',
);


sub Run {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for (qw(Config)) {
        if ( !$Param{$_} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $_!"
            );
            return;
        }
    }

    # check if frontend module is used
    my $Action = $Param{Config}->{Action};
    if ($Action) {
        return if !$Kernel::OM->Get('Kernel::Config')->Get('Frontend::Module')->{$Action};
    }
    # get ticket object
    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');

    # get user lock data

    my $QueueObject = $Kernel::OM->Get('Kernel::System::Queue');
    my @CustomQueueIDs = $QueueObject->GetAllCustomQueues(
        UserID => $Self->{UserID}
    );

    my $Count = $TicketObject->TicketSearch(
        Result     => 'COUNT',
	StateType	=> ['open', 'new'],
        UserID   => [ $Self->{UserID} ],
        UserID     => 1,
	QueueIDs => \@CustomQueueIDs,
        Permission => 'ro',
    );

    # get layout object
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    # get item definition
    my $Text      = $LayoutObject->{LanguageObject}->Translate( $Param{Config}->{Name} );
    my $URL       = $LayoutObject->{Baselink} . $Param{Config}->{Link};
    my $Priority  = $Param{Config}->{Priority};
    my $AccessKey = $Param{Config}->{AccessKey};
    my $CssClass  = $Param{Config}->{CssClass};
    my $Icon      = $Param{Config}->{Icon};
    my $IconNew     = $Param{Config}->{IconNew};
    my $IconReached = $Param{Config}->{IconReached};
    my $ClassNew     = $Param{Config}->{CssClassNew};
    my $ClassReached = $Param{Config}->{CssClassReached};

#   my $QueueObject = $Kernel::OM->Get('Kernel::System::Queue');
#    my @CustomQueueIDs = $QueueObject->GetAllCustomQueues(
#        UserID => $Self->{UserID}
#    );

my %Return;
        $Return{ $Priority++ } = {
            Block       => 'ToolBarItem',
            Count       => $Count,
            Description => $Text,
            Class       => $CssClass,
            Icon        => $Icon,
#            Link        =>  $URL . 'AgentTicketQueue;QueueID=0;View=;Filter=Unlocked;UseSubQueues=0',
            Link        =>  $URL . ';QueueID=0;View=;Filter=Unlocked;UseSubQueues=0',
#            AccessKey   => $Param{Config}->{AccessKey} || '',
        AccessKey   => $AccessKey,
        };


    return %Return;
}

1;
