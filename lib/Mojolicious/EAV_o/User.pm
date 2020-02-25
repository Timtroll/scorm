package Kernel::System::EAV::User;

use parent 'Kernel::System::EAV::Base';
use strict;
use warnings;

sub GetSubscriptions {
    my $Self = shift;
    return undef unless exists( $Self->{_item} ); ## no critic

    my $LH = Kernel::System::EAV->new( 'Location' );

    my $Result = [];

    my $AllSubs = [];
    my $DirectUserSubsSQL = 'SELECT s.*, -1 AS "distance" FROM "public"."EAV_submodules_subscriptions" AS s INNER JOIN "public"."EAV_items" AS i ON i."id" = s."subscription_id" AND i."publish" = true WHERE s."owner_id" = '.$Self->{_item}->{id};
    my $DirectUserSubs = $Self->{DBObject}->SelectAllHR( $DirectUserSubsSQL );
    push @$AllSubs, @$DirectUserSubs;
    my $Offset = scalar( @$AllSubs );

    #тут привязка идёт через subscriptions.address - в теории кроме адреса там ничего быть не может.
    my $OfficeCrossAddressSQL =
        'SELECT s.*, lO."distance" FROM '.
        '"public"."EAV_links" AS lO '.
        'INNER JOIN "public"."EAV_links" AS lA ON lA."id" = lO."id" '.
        'INNER JOIN "public"."EAV_submodules_subscriptions" AS s ON s."owner_id" = lO."parent" AND s."address_id" = lA."parent" '.
        'INNER JOIN "public"."EAV_items" AS i ON i."id" = s."subscription_id" AND i."publish" = true '.
        'WHERE lO."id" = '.$Self->{_item}->{id};
    my $CrossSubs = $Self->{DBObject}->SelectAllHR( $OfficeCrossAddressSQL );
    push @$AllSubs, map { $_->{distance} += $Offset; $_ } @$CrossSubs;
    $Offset = scalar( @$AllSubs );

    #тут мы выбираем все подписки через парентов юзера.
    my $OfficeOrAddressSQL = 'SELECT s.*, l."distance" FROM '.
    '"public"."EAV_links" AS l '.
    'INNER JOIN "public"."EAV_submodules_subscriptions" AS s ON s."owner_id" = l."parent" AND s."address_id" = 0 '.
    'INNER JOIN "public"."EAV_items" AS i ON i."id" = s."subscription_id" AND i."publish" = true '.
    'WHERE l."id" = '.$Self->{_item}->{id};
    my $OfficeOrAddressSubs = $Self->{DBObject}->SelectAllHR( $OfficeOrAddressSQL );

    #сначала кладём подписки от офиса.
    push @$AllSubs, map { $_->{distance} += $Offset; $_ } grep { $_->{owner_type} eq 'office' } @$OfficeOrAddressSubs;
    $Offset = scalar( @$AllSubs );

    #теперь от адресов
    push @$AllSubs, map { $_->{distance} += $Offset; $_ } grep { $_->{owner_type} eq 'location' } @$OfficeOrAddressSubs;

    #вычищаем запреты
    #запрет вычищается по уровням ( запреты адреса => подразделения => слабее чем сервисы+сла навешанные на адрес+поздразделение => или на юзера лично ).
    my $Deny = {};
    foreach my $s ( sort { $a->{distance} <=> $b->{distance} } @$AllSubs ) {
####        next if ( defined( $Seen{ $s->{service_id} } ) ); не правильно, сначала надо проверять deny
####        $Seen{ $s->{service_id} } = 1;
        if ( $s->{deny} ) {
            $Deny->{ $s->{service_id} } = 1;
            next;
        }
        next if exists( $Deny->{ $s->{service_id} } );

        push @$Result, $s;
    }

    # делаем дистинкт по сервисам.
    # докидываем информацию по сервису
    my $Tmp = {};
    my $ServiceObj = $Kernel::OM->Get('Kernel::System::Service');

    $Result = [
        map {
            my $s       = $_;
            my %Service = $ServiceObj->ServiceGet(
                ServiceID => $s->{service_id},
                UserID    => 1
            );
            $s->{Service} = \%Service if (%Service);
            $s
        } grep {
            !exists( $Tmp->{ $_->{service_id} } )
                && ( $Tmp->{ $_->{service_id} } = 1 )
            } @$Result
    ];

    return $Result;
}


=head2 SLAGet( %Param )

Метод возвращает SLA на основе подписки

my @Subscription = $EAVObject->GetSubscription(
    Priority        => '3 высокий', #Приоритет - необязательно
    PriorityID      => '3',         #ID приоритета - необязательно
    TicketType      => 'Инцидент'   #Тип тикета - TicketType или TicketTypeID - обязательно
    TicketTypeID    => '2'          #ID типа тикета - TicketType или TicketTypeID - обязательно
);

Метод возвращает Hash: SLAID => SLAName
=cut

sub SLAGet{
    my ( $Self, %Param ) = @_;

    unless ( defined( $Param{ServiceID} ) && ( defined( $Param{TicketType} ) || defined( $Param{TicketTypeID} ) ) ){
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority    => 'error',
            Message     => 'Mandatory parameters is missing'
        );
        return;
    }

    my $Subscriptions = $Self->GetSubscriptions();

    unless( $Subscriptions && ref( $Subscriptions ) eq 'ARRAY' && @$Subscriptions ){
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority    => 'error',
            Message     => 'Can\'t find subscriptions!'
        );
        return;
    }

    my $SLAGroupObject = $Kernel::OM->Get('Kernel::System::SLAGroup');
    my $SLAObject = $Kernel::OM->Get('Kernel::System::SLA');

    my $Result;
    for my $Item( @$Subscriptions ){
        next if( $Item->{service_id} != $Param{ServiceID} );
        my $SLAID = $SLAGroupObject->SLAGet(
            SLAGroupID   => $Item->{sla_id},
            %Param
        );
        next if( !defined($SLAID) );

        my %SLA = $SLAObject->SLAGet(
            SLAID   => $SLAID,
            UserID  => 1
        );
        if( %SLA ){
            return { SLAID => $SLAID, SLAName => $SLA{Name} };
        }
    }

    $Kernel::OM->Get('Kernel::System::Log')->Log(
        Priority    => 'error',
        Message     => 'PANIC!!! It\'s seems like we have subscription that leads to SLA-Group with wrong rules'
    );
    $Kernel::OM->Get('Kernel::System::Log')->Dumper({
        Subscription    => $Subscriptions,
        Params          => \%Param
    });

    return;
}
1;
