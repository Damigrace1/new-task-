<?php

/*
SELECT userid, DATE(actiondate) as date, TIMEDIFF(MAX(actiondate), MIN(actiondate)) as hours 
FROM punchin
where userid=33 and todaydate='2020-08-25'
GROUP BY userid, todaydate

SELECT userid, DATE(actiondate) as date, TIMEDIFF(MAX(actiondate), MIN(actiondate)) as hours 
FROM punchin
where userid=41 and SUBSTRING(todaydate, 6, 2) = "08"
GROUP BY userid, todaydate 
SELECT userid, SEC_TO_TIME(SUM(TIME_TO_SEC(MAX(actiondate)) - TIME_TO_SEC(MIN(actiondate)))) AS timediff
    FROM punchin where userid=41 and SUBSTRING(todaydate, 6, 2) = "08"
*/
define('API_ACCESS_KEY','AAAAAx8_NXQ:APA91bGxWNhRFJfG8RPh4ASbqfcCzC5pbv6eRo5xSi33w2G7Lbdj6PIInv5MQizoAV6cgSPWVjw4YxlsOO8NiHywHf9F3rsOe-feVvRh3g8JCWlbrjXEQD8ydnFBXDUaZK8xh8CWLfEk');
 $fcmUrl = 'https://fcm.googleapis.com/fcm/send';

$token = 'd-MM_ZfktB8:APA91bFTB2dnRA1UGgEdroABD4s8nzQpg5zOg8O9wm2vOhveEPDRKzcJbMOApUKlUm4EMAvIgF2foCZBNjkp0jQj4TniMvpJRCK_Dq-sPiCw137TsQ6uQrjDCJSh00DbQ-g5CPo5QjSe';
     $notification = [
            'title' =>'Keep Connected',
            'body' => "Please don't forget to checkin this morning.",
            'icon' =>'myIcon',
            'sound' => 'mySound'
        ];
        $extraNotificationData = ["message" => $notification,"moredata" =>'dd'];

        $fcmNotification = [
            
            'to'        => $token,
            'notification' => $notification,
            'data' => $extraNotificationData
        ];

        $headers = [
            'Authorization: key=' . API_ACCESS_KEY,
            'Content-Type: application/json'
        ];


        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL,$fcmUrl);
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
        curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($fcmNotification));
        $result = curl_exec($ch);
        curl_close($ch);

        var_dump($result);


?>
~           